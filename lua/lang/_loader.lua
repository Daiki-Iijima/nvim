local M = {}

-- 共通 capabilities（nvim-cmp 連携用）
local function make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end
  return capabilities
end

-- 共通 on_attach（ここで LSP のショートカットを定義）
local function on_attach(_, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- 🔍 定義/参照まわり
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

  -- ℹ️ 情報表示
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

  -- 🛠 リファクタリング
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

  -- ⚠️ 診断ジャンプ
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

  -- 🧹 フォーマット
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)

  -- 診断を Quickfix に流して開く
  vim.keymap.set("n", "<leader>dq", function()
    vim.diagnostic.setqflist()
    vim.cmd("copen")
  end, { desc = "Diagnostics → quickfix" })

  -- 現在バッファだけ Quickfix に流す
  vim.keymap.set("n", "<leader>db", function()
    vim.diagnostic.setqflist({ bufnr = 0 })
    vim.cmd("copen")
  end, { desc = "Buffer diagnostics → quickfix" })
end

function M.setup()
  local capabilities = make_capabilities()

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
  require("lang.cpp").setup()

  -- 有効化したい LSP を起動
  vim.lsp.enable({
    "sourcekit", -- Swift
    "lua_ls",    -- Lua
    "pyright",   -- python
    "gopls",     -- Go
    "csharp_ls", -- C#
    "clangd",    -- C,C++
  })
end

return M
