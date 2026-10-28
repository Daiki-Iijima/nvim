local M = {}

-- プロジェクトの node_modules の typescript が 7 以上か。
-- TS7 には tsserver が無いので ts_ls（typescript-language-server）は使えず、tsc --lsp を使う。
local function is_ts7(root)
  local f = io.open(vim.fs.joinpath(root, "node_modules/typescript/package.json"))
  if not f then return false end
  local ok, pkg = pcall(vim.json.decode, f:read("*a"))
  f:close()
  local major = ok and type(pkg) == "table" and tonumber(tostring(pkg.version):match("^(%d+)"))
  return (major or 0) >= 7
end

function M.setup()
  -- cmd・filetypes・root_dir は nvim-lspconfig の lsp/ts_ls.lua を使う
  local ts_ls = vim.lsp.config.ts_ls

  --------------------------------------------------------------------
  -- TypeScript / JavaScript LSP（ts_ls）: TS6 までのプロジェクト
  --------------------------------------------------------------------
  vim.lsp.config("ts_ls", {
    root_dir = function(bufnr, on_dir)
      ts_ls.root_dir(bufnr, function(root)
        if not is_ts7(root) then on_dir(root) end
      end)
    end,
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
  -- TypeScript 7 のプロジェクト: node_modules/.bin/tsc --lsp --stdio
  --------------------------------------------------------------------
  vim.lsp.config("tsc_lsp", {
    cmd = function(dispatchers, config)
      return vim.lsp.rpc.start(
        { vim.fs.joinpath(config.root_dir, "node_modules/.bin/tsc"), "--lsp", "--stdio" },
        dispatchers
      )
    end,
    filetypes = ts_ls.filetypes,
    root_dir = function(bufnr, on_dir)
      ts_ls.root_dir(bufnr, function(root)
        if is_ts7(root) then on_dir(root) end
      end)
    end,
  })

  -- ESLint は LSP（eslint）だけ使う。設定は nvim-lspconfig の既定のまま。

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
