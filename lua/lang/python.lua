local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- Python: 型は basedpyright、lint・import 整理・整形は ruff
  -- （cmd・filetypes・root_markers は nvim-lspconfig の既定）
  --   uv tool install basedpyright / brew install ruff
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("basedpyright", {
    settings = {
      basedpyright = {
        disableOrganizeImports = true, -- import 整理は ruff に任せる
        analysis = {
          typeCheckingMode = "basic", -- "off" | "basic" | "standard" | "recommended" | "strict"
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace", -- "openFilesOnly" でもOK
        },
      },
    },
  })

  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
  end
end

return M
