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
  -- Formatter（Conform / Pint）
  --------------------------------------------------------------------
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.setup({
      formatters_by_ft = {
        php = { "pint" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end
end

return M
