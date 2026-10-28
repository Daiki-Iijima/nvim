local M = {}

-- capabilities は blink.cmp が vim.lsp.config("*") に自動で設定する（plugin/blink-cmp.lua）

-- コードブロック・インラインコードをプレースホルダに退避
local function mask_code(text)
  local blocks = {}
  local counter = 0
  local result_lines = {}
  local in_fence = false
  local fence_lines = {}
  local fence_ph = nil

  for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
    if not in_fence and line:match("^```") then
      in_fence = true
      fence_lines = { line }
      counter = counter + 1
      fence_ph = '<x id="' .. counter .. '"/>'
      table.insert(result_lines, fence_ph)
    elseif in_fence and line:match("^```") then
      in_fence = false
      table.insert(fence_lines, line)
      blocks[fence_ph] = table.concat(fence_lines, "\n")
      fence_lines = {}
      fence_ph = nil
    elseif in_fence then
      table.insert(fence_lines, line)
    else
      local masked = line:gsub("`([^`\n]+)`", function(code)
        counter = counter + 1
        local ph = '<x id="' .. counter .. '"/>'
        blocks[ph] = "`" .. code .. "`"
        return ph
      end)
      table.insert(result_lines, masked)
    end
  end
  if in_fence and fence_ph then
    blocks[fence_ph] = table.concat(fence_lines, "\n")
  end

  return table.concat(result_lines, "\n"), blocks
end

-- プレースホルダをコードブロックに戻す
-- Google Translate がスペースを入れる場合があるので id 番号でパターンマッチ
local function unmask_code(text, blocks)
  return (text:gsub('<x%s+id%s*=%s*"(%d+)"%s*/>', function(id)
    local ph = '<x id="' .. id .. '"/>'
    local content = blocks[ph]
    return content and content:gsub("%%", "%%%%") or ph
  end))
end

-- 日本語に翻訳する（K と <leader>e を押したときだけ Google 翻訳に送る）
local translation_cache = {}

local function translate_text(text, cb)
  if not text or text == "" then
    cb(text)
    return
  end

  if translation_cache[text] then
    cb(translation_cache[text])
    return
  end

  local masked_text, code_blocks = mask_code(text)

  vim.system(
    { "curl", "-s", "https://translate.googleapis.com/translate_a/single",
      "-G", "--data-urlencode", "q=" .. masked_text,
      "-d", "client=gtx&sl=auto&tl=ja&dt=t" },
    { text = true },
    function(res)
      if res.code ~= 0 or not res.stdout or res.stdout == "" then
        vim.schedule(function() cb(text) end)
        return
      end

      local ok, data = pcall(vim.json.decode, res.stdout)
      if not ok or type(data) ~= "table" or not data[1] then
        vim.schedule(function() cb(text) end)
        return
      end

      local translated_parts = {}
      for _, segment in ipairs(data[1]) do
        if type(segment) == "table" and type(segment[1]) == "string" then
          table.insert(translated_parts, segment[1])
        end
      end
      local translated = table.concat(translated_parts, "")

      if translated ~= "" then
        translated = unmask_code(translated, code_blocks)
        translation_cache[text] = translated
        vim.schedule(function() cb(translated) end)
      else
        vim.schedule(function() cb(text) end)
      end
    end
  )
end

local function open_markdown_float(text)
  vim.lsp.util.open_floating_preview(vim.split(text, "\n", { plain = true }), "markdown", { focusable = true })
end

local function translated_hover(bufnr)
  local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
  local encoding = client and client.offset_encoding or "utf-16"
  local params = vim.lsp.util.make_position_params(0, encoding)
  vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(_, result)
    if not result or not result.contents then return end

    -- ホバー内容をテキストに変換
    local contents = result.contents
    local text = ""
    if type(contents) == "string" then
      text = contents
    elseif type(contents) == "table" then
      if contents.value then
        text = contents.value
      else
        local parts = {}
        for _, item in ipairs(contents) do
          table.insert(parts, type(item) == "string" and item or (item.value or ""))
        end
        text = table.concat(parts, "\n")
      end
    end

    if text == "" then return end
    translate_text(text, open_markdown_float)
  end)
end

-- カーソル行の診断を日本語に翻訳してフロート表示
local function translated_diagnostic_float()
  local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if vim.tbl_isempty(diags) then
    vim.diagnostic.open_float()
    return
  end

  local messages = {}
  for _, d in ipairs(diags) do
    table.insert(messages, "[" .. vim.diagnostic.severity[d.severity] .. "] " .. d.message)
  end
  translate_text(table.concat(messages, "\n"), open_markdown_float)
end

-- LSP のショートカット（LspAttach で張る。nvim-lspconfig の ts_ls・basedpyright・eslint・clangd は
-- 自前の on_attach を持ち vim.lsp.config("*") の on_attach を上書きするため、on_attach では張らない）
-- 参照・実装・型定義・リネーム・コードアクション・診断ジャンプ・シグネチャは Neovim 既定のキーを使う:
--   grr 参照 / gri 実装 / grt 型定義 / grn リネーム / gra コードアクション / grx CodeLens
--   [d ]d 診断ジャンプ / 挿入モード <C-s> シグネチャヘルプ
local function set_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- 🔍 定義/宣言
  vim.keymap.set("n", "gd", vim.lsp.buf.definition,  vim.tbl_extend("force", opts, { desc = "定義へジャンプ" }))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "宣言へジャンプ" }))

  -- ℹ️ 情報表示
  vim.keymap.set("n", "K",  function() translated_hover(bufnr) end, vim.tbl_extend("force", opts, { desc = "ホバー情報を日本語で表示" }))
  vim.keymap.set("n", "gK", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "ホバー情報を原文で表示" }))

  -- 🛠 リファクタリング
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      vim.tbl_extend("force", opts, { desc = "シンボルをリネーム" }))
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "コードアクションを表示" }))

  -- 🪟 ホバーウィンドウのスクロール
  local function scroll_float(delta)
    local win = vim.b.lsp_floating_preview
    if not win or not vim.api.nvim_win_is_valid(win) then return false end
    vim.api.nvim_win_call(win, function()
      local view = vim.fn.winsaveview()
      view.topline = math.max(1, view.topline + delta)
      vim.fn.winrestview(view)
    end)
    return true
  end

  vim.keymap.set("n", "<C-d>", function()
    if not scroll_float(4) then return "<C-d>" end
  end, { expr = true, buffer = bufnr, silent = true, desc = "ホバー/画面を下スクロール" })

  vim.keymap.set("n", "<C-u>", function()
    if not scroll_float(-4) then return "<C-u>" end
  end, { expr = true, buffer = bufnr, silent = true, desc = "ホバー/画面を上スクロール" })

  -- ⚠️ 診断
  vim.keymap.set("n", "<leader>e", translated_diagnostic_float,
    vim.tbl_extend("force", opts, { desc = "診断エラーの詳細を日本語でフロート表示" }))

  -- 診断を Quickfix に流して開く
  vim.keymap.set("n", "<leader>dq", function()
    vim.diagnostic.setqflist()
    vim.cmd("copen")
  end, { desc = "全診断エラーをQuickfixに表示" })

  -- 現在バッファだけ Quickfix に流す
  vim.keymap.set("n", "<leader>db", function()
    vim.diagnostic.setqflist({ bufnr = 0 })
    vim.cmd("copen")
  end, { desc = "現在バッファの診断エラーをQuickfixに表示" })
end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lang_loader_keymaps", {}),
    callback = function(args) set_keymaps(args.buf) end,
  })

  -- 言語ごとの設定（ここで個別モジュールを呼ぶ）
  require("lang.swift").setup()
  require("lang.lua").setup()
  require("lang.python").setup()
  require("lang.go").setup()
  require("lang.csharp").setup()
  require("lang.php").setup()
  require("lang.typescript").setup()
  require("lang.web").setup()    -- HTML / CSS / Tailwind / Emmet / JSON / YAML
  require("lang.cpp").setup()    -- C / C++ / Objective-C (clangd)

  -- 有効化したい LSP を起動（cmd が PATH に無いサーバーは Neovim が起動しない＝入っていれば使う）
  -- ※ rust_analyzer は rustaceanvim が管理するため除外
  vim.lsp.enable({
    "sourcekit",              -- Swift
    "lua_ls",                 -- Lua
    "basedpyright",           -- Python（型）
    "ruff",                   -- Python（lint / import 整理）
    "gopls",                  -- Go
    "csharp_ls",              -- C#
    "intelephense",           -- PHP
    "ts_ls",                  -- TypeScript / JavaScript（TS6 まで）
    "tsc_lsp",                -- TypeScript 7 の tsc --lsp（lang/typescript.lua）
    "eslint",                 -- ESLint
    "clangd",                 -- C / C++
    -- Web
    "html",                   -- HTML
    "cssls",                  -- CSS / SCSS / Less
    "tailwindcss",            -- Tailwind CSS
    "emmet_language_server",  -- Emmet
    "jsonls",                 -- JSON
    "yamlls",                 -- YAML
  })
end

return M
