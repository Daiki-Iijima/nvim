local M = {}

function M.setup()
  -- Lua 用 LSP 設定（lua-language-server）
  -- cmd・filetypes・root_markers は nvim-lspconfig の既定。Neovim の型情報は lazydev.nvim が渡す。
  ---@type vim.lsp.Config
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" }, -- Neovim は LuaJIT
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  })

  -- フォーマッタ: stylua を Conform に登録
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.lua = { "stylua" }
  end
end

return M
