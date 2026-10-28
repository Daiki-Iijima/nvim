local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- PHP / Laravel LSP（intelephense）
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("intelephense", {
    cmd = { "intelephense", "--stdio" },
    filetypes = { "php" },
    root_markers = { "composer.json", ".git" },
    settings = {
      intelephense = {
        files = { maxSize = 5000000 },
      },
    },
  })

  --------------------------------------------------------------------
  -- Formatter（Conform / Pint）: setup は plugins/lsp.lua の 1 回だけ。ここでは php を足すだけ
  --------------------------------------------------------------------
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.php = { "pint" }
  end
end

return M
