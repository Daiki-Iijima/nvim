local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- C#（Unity）用 LSP: csharp-ls
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("csharp_ls", {
    cmd = { "csharp-ls" },
    filetypes = { "cs", "csharp" },
    root_markers = {
      "Project.csproj",
      "global.json",
      ".git",
    },

    settings = {
      csharp = {
        formatting = {
          enable = true,
        },
        semanticTokens = {
          enable = true,
        },
        diagnostics = {
          enable = true,
        },
      },
    },
  })

  --------------------------------------------------------------------
  -- Conform フォーマッタ（C#）
  --------------------------------------------------------------------
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}

    -- dotnet-format を使うやつ（Unity プロジェクトでも動く）
    conform.formatters_by_ft.cs = { "dotnet_format" }
  end
end

return M
