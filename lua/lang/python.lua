local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- Python 用 LSP 設定（pyright）
  --------------------------------------------------------------------
  ---@type vim.lsp.Config
  vim.lsp.config("pyright", {
    cmd = { "pyright-langserver", "--stdio" }, -- `pyright-langserver` が PATH に必要
    filetypes = { "python" },
    root_markers = {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
      ".git",
    },
    settings = {
      python = {
        analysis = {
          -- 型チェックの厳しさ
          typeCheckingMode = "basic", -- "off" | "basic" | "strict"
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace", -- "openFilesOnly" でもOK
        },
        -- 仮想環境を固定したい場合はこんな感じで
        -- venvPath = "/path/to/.venv/root",
        -- venv = "myenv",
      },
    },
  })

  --------------------------------------------------------------------
  -- フォーマッタ: black / isort / ruff などを Conform に登録
  --------------------------------------------------------------------
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}

    -- すでに他の設定があっても潰さないようにマージする形でもOK
    conform.formatters_by_ft.python = { "black" }
    -- black + isort にしたければ:
    -- conform.formatters_by_ft.python = { "isort", "black" }
    -- ruff-format を使うなら:
    -- conform.formatters_by_ft.python = { "ruff_format" }
  end
end

return M
