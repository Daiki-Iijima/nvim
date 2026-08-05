local M = {}

-- 共通 capabilities（blink.cmp または nvim-cmp 連携用）
local function make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  else
    local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp then
      capabilities = cmp_lsp.default_capabilities(capabilities)
    end
  end
  return capabilities
end

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

-- ホバー内容を日本語に翻訳してフロート表示
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

    translate_text(text, function(translated)
      local lines = vim.split(translated, "\n", { plain = true })
      vim.lsp.util.open_floating_preview(lines, "markdown", {
        border = "rounded",
        focusable = true,
        wrap = true,
      })
    end)
  end)
end

-- カーソル位置の診断を日本語に翻訳してフロート表示
local function translated_diagnostic_float()
  local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if vim.tbl_isempty(diags) then
    vim.diagnostic.open_float()
    return
  end

  -- メッセージを結合
  local messages = {}
  for _, d in ipairs(diags) do
    local severity = ({
      [vim.diagnostic.severity.ERROR] = "ERROR",
      [vim.diagnostic.severity.WARN]  = "WARN",
      [vim.diagnostic.severity.INFO]  = "INFO",
      [vim.diagnostic.severity.HINT]  = "HINT",
    })[d.severity] or "?"
    table.insert(messages, "[" .. severity .. "] " .. d.message)
  end
  local text = table.concat(messages, "\n")

  vim.system(
    { "curl", "-s", "https://translate.googleapis.com/translate_a/single",
      "-G", "--data-urlencode", "q=" .. text,
      "-d", "client=gtx&sl=auto&tl=ja&dt=t" },
    { text = true },
    function(res)
      if res.code ~= 0 or not res.stdout or res.stdout == "" then
        vim.schedule(function() vim.diagnostic.open_float() end)
        return
      end

      local ok, data = pcall(vim.json.decode, res.stdout)
      if not ok or type(data) ~= "table" or not data[1] then
        vim.schedule(function() vim.diagnostic.open_float() end)
        return
      end

      local parts = {}
      for _, segment in ipairs(data[1]) do
        if type(segment) == "table" and type(segment[1]) == "string" then
          table.insert(parts, segment[1])
        end
      end
      local translated = table.concat(parts, "")

      if translated == "" then
        vim.schedule(function() vim.diagnostic.open_float() end)
        return
      end

      vim.schedule(function()
        local lines = vim.split(translated, "\n", { plain = true })
        vim.lsp.util.open_floating_preview(lines, "markdown", {
          border = "rounded",
          focusable = true,
          wrap = true,
        })
      end)
    end
  )
end

-- 共通 on_attach（ここで LSP のショートカットを定義）
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- completionItem/resolve のリクエストをフックして日本語翻訳
  if client and not client._completion_resolve_hooked then
    client._completion_resolve_hooked = true
    local orig_request = client.request
    client.request = function(self, method, params, handler, req_bufnr)
      if method == "completionItem/resolve" and handler then
        local orig_handler = handler
        handler = function(err, result, ctx, config)
          if err or not result then
            return orig_handler(err, result, ctx, config)
          end

          local doc = result.documentation
          if not doc then
            return orig_handler(err, result, ctx, config)
          end

          if type(doc) == "string" then
            translate_text(doc, function(translated)
              result.documentation = translated
              orig_handler(err, result, ctx, config)
            end)
          elseif type(doc) == "table" and type(doc.value) == "string" then
            translate_text(doc.value, function(translated)
              result.documentation.value = translated
              orig_handler(err, result, ctx, config)
            end)
          else
            return orig_handler(err, result, ctx, config)
          end
          return
        end
      end
      return orig_request(self, method, params, handler, req_bufnr)
    end
  end

  -- 🔍 定義/参照まわり
  vim.keymap.set("n", "gd", vim.lsp.buf.definition,    vim.tbl_extend("force", opts, { desc = "定義へジャンプ" }))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration,   vim.tbl_extend("force", opts, { desc = "宣言へジャンプ" }))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "実装へジャンプ" }))
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "型定義へジャンプ" }))
  vim.keymap.set("n", "gr", vim.lsp.buf.references,    vim.tbl_extend("force", opts, { desc = "参照一覧を表示" }))

  -- ℹ️ 情報表示
  vim.keymap.set("n", "K",    function() translated_hover(bufnr) end, vim.tbl_extend("force", opts, { desc = "ホバー情報を日本語で表示" }))
  vim.keymap.set("n", "gK",   vim.lsp.buf.hover,         vim.tbl_extend("force", opts, { desc = "ホバー情報を原文で表示" }))
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "シグネチャヘルプを表示" }))

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

  -- ⚠️ 診断ジャンプ
  vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
  end, vim.tbl_extend("force", opts, { desc = "前の診断エラーへ移動" }))

  vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
  end, vim.tbl_extend("force", opts, { desc = "次の診断エラーへ移動" }))

  vim.keymap.set("n", "<leader>e", translated_diagnostic_float,
    vim.tbl_extend("force", opts, { desc = "診断エラーの詳細を日本語でフロート表示" }))

  -- 🧹 フォーマット
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", opts, { desc = "ファイルをフォーマット" }))

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

local function translate_diagnostics(err, result, ctx, config, orig_handler)
  if not result or not result.diagnostics or #result.diagnostics == 0 then
    orig_handler(err, result, ctx, config)
    return
  end

  local to_translate = {}
  local indices = {}

  for i, d in ipairs(result.diagnostics) do
    local msg = d.message
    if translation_cache[msg] then
      d.message = translation_cache[msg]
    else
      table.insert(to_translate, msg)
      table.insert(indices, i)
    end
  end

  if #to_translate == 0 then
    orig_handler(err, result, ctx, config)
    return
  end

  local separator = "\n___\n"
  local combined = table.concat(to_translate, separator)

  vim.system(
    { "curl", "-s", "https://translate.googleapis.com/translate_a/single",
      "-G", "--data-urlencode", "q=" .. combined,
      "-d", "client=gtx&sl=auto&tl=ja&dt=t" },
    { text = true },
    function(res)
      if res.code ~= 0 or not res.stdout or res.stdout == "" then
        vim.schedule(function()
          orig_handler(err, result, ctx, config)
        end)
        return
      end

      local ok, decoded = pcall(vim.json.decode, res.stdout)
      if not ok or type(decoded) ~= "table" or not decoded[1] then
        vim.schedule(function()
          orig_handler(err, result, ctx, config)
        end)
        return
      end

      local translated_parts = {}
      for _, segment in ipairs(decoded[1]) do
        if type(segment) == "table" and type(segment[1]) == "string" then
          table.insert(translated_parts, segment[1])
        end
      end
      local translated_text = table.concat(translated_parts, "")

      -- スペース調整と分割
      local normalized = translated_text:gsub("%s*___%s*", "___")
      local translated_messages = vim.split(normalized, "___", { plain = true })

      vim.schedule(function()
        for idx, i in ipairs(indices) do
          local orig_msg = to_translate[idx]
          local trans_msg = translated_messages[idx] or orig_msg
          trans_msg = trans_msg:gsub("^%s*(.-)%s*$", "%1")
          translation_cache[orig_msg] = trans_msg
          result.diagnostics[i].message = trans_msg
        end
        orig_handler(err, result, ctx, config)
      end)
    end
  )
end

M.on_attach = on_attach

function M.setup()
  local capabilities = make_capabilities()

  -- ホバーとシグネチャヘルプで折り返し表示 (wrap) を有効化し、見やすくする
  local orig_hover = vim.lsp.handlers["textDocument/hover"] or vim.lsp.handlers.hover
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, {
      border = "rounded",
      wrap = true,
      max_width = 80,
    })
    return orig_hover(err, result, ctx, config)
  end

  local orig_sig_help = vim.lsp.handlers["textDocument/signatureHelp"] or vim.lsp.handlers.signature_help
  vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, {
      border = "rounded",
      wrap = true,
      max_width = 80,
    })
    return orig_sig_help(err, result, ctx, config)
  end

  -- publishDiagnostics ハンドラーをフックして診断を自動日本語翻訳
  local orig_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
    translate_diagnostics(err, result, ctx, config, orig_publish)
  end


  -- すべての LSP に共通で適用する設定
  ---@type vim.lsp.Config
  vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- 言語ごとの設定（ここで個別モジュールを呼ぶ）
  require("lang.swift").setup()
  require("lang.lua").setup()
  require("lang.python").setup()
  require("lang.go").setup()
  require("lang.csharp").setup()
  require("lang.rust").setup()   -- rustaceanvim が管理するため実質 no-op
  require("lang.php").setup()
  require("lang.typescript").setup()
  require("lang.web").setup()    -- HTML / CSS / Tailwind / Emmet / JSON / YAML
  require("lang.cpp").setup()    -- C / C++ / Objective-C (clangd)

  -- 有効化したい LSP を起動
  -- ※ rust_analyzer は rustaceanvim が管理するため除外
  vim.lsp.enable({
    "sourcekit",              -- Swift
    "lua_ls",                 -- Lua
    "pyright",                -- Python
    "gopls",                  -- Go
    "csharp_ls",              -- C#
    "intelephense",           -- PHP
    "ts_ls",                  -- TypeScript / JavaScript
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
