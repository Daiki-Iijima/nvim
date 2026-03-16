local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- TypeScript / JavaScript LSP（ts_ls）
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
    },
    root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    },
  })

  --------------------------------------------------------------------
  -- ESLint LSP（eslint が PATH に必要）
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("eslint", {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    filetypes = {
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
    },
    root_markers = {
      ".eslintrc", ".eslintrc.js", ".eslintrc.cjs",
      ".eslintrc.json", "eslint.config.js", "eslint.config.mjs",
      "package.json", ".git",
    },
    settings = {
      validate = "on",
      rulesCustomizations = {},
      run = "onType",
      problems = { shortenToSingleLine = false },
      codeAction = {
        disableRuleComment = { enable = true, location = "separateLine" },
        showDocumentation = { enable = true },
      },
    },
  })

  --------------------------------------------------------------------
  -- フォーマッタ: prettier を Conform に登録
  --------------------------------------------------------------------
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.javascript      = { "prettier" }
    conform.formatters_by_ft.javascriptreact = { "prettier" }
    conform.formatters_by_ft.typescript      = { "prettier" }
    conform.formatters_by_ft.typescriptreact = { "prettier" }
    -- html / css / json は web.lua で設定
  end
end

return M
