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

    -- conform に dotnet_format は無い。csharpier（dotnet tool install -g csharpier）が入っていれば使い、
    -- 無ければ csharp-ls の整形にフォールバックする
    conform.formatters_by_ft.cs = { "csharpier" }
  end
end

return M
