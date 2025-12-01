local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- Go 用 LSP 設定（gopls）
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("gopls", {
    cmd = { "gopls" }, -- gopls が PATH に必要
    filetypes = { "go", "gomod", "gowork" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        analyses = {
          unusedparams = true,
          shadow = true,
        },
      },
    },
  })

  --------------------------------------------------------------------
  -- フォーマッタ: goimports / gofmt を Conform に登録（お好みで）
  --------------------------------------------------------------------
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    -- goimports を使う場合
    conform.formatters_by_ft.go = { "goimports" }
    -- gofmt だけなら ↓ に変える
    -- conform.formatters_by_ft.go = { "gofmt" }
  end
end

return M
