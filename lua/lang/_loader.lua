-- ~/.config/nvim/lua/lang/_loader.lua

-- 共通 capabilities（nvim-cmp 連携用）
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = vim.lsp.protocol.make_client_capabilities()
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- 共通 on_attach（ここで LSP のショートカットを定義）
local function on_attach(_, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- 🔍 定義/参照まわり
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)        -- 定義へジャンプ
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)       -- 宣言へジャンプ
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)    -- 実装へ
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)   -- 型定義へ
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)        -- 参照一覧

  -- ℹ️ 情報表示
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)              -- ホバー（型/コメント）
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts) -- シグネチャヘルプ

  -- 🛠 リファクタリング
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)    -- 変数名リネーム
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Code Action

  -- ⚠️ 診断ジャンプ
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)      -- 前のエラーへ
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)      -- 次のエラーへ
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- ポップアップ表示

  -- 🧹 フォーマット
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- すべての LSP に共通で適用する設定
vim.lsp.config("*", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Swift / SourceKit 用の個別設定
vim.lsp.config("sourcekit", {
  cmd = { "xcrun", "sourcekit-lsp" },
  root_markers = {
    "Package.swift",
    ".git",
    "*.xcodeproj",
    "*.xcworkspace",
    "buildServer.json",
  },
})

-- 有効化したい LSP を起動
vim.lsp.enable({
  "sourcekit",
  -- "gopls", みたいに他の LSP をここに追加もできる
})

