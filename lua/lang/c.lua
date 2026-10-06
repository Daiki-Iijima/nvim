local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- C / C++ 用 LSP 設定（clangd）
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("clangd", {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    root_markers = { "compile_commands.json", ".clangd", ".git" },
  })

  --------------------------------------------------------------------
  -- フォーマッタ: clang-format を Conform に登録
  --------------------------------------------------------------------
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.c   = { "clang-format" }
    conform.formatters_by_ft.cpp = { "clang-format" }
  end
end

return M
