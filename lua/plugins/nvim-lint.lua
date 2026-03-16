-- =============================================================================
-- nvim-lint: 非同期 Linter 統合
-- =============================================================================
-- ファイル保存時・読み込み時・インサート離脱時に自動でリンターを実行し、
-- 結果を Neovim の diagnostics（警告・エラー表示）に流す。
--
-- conform.nvim がフォーマット（整形）を担当するのに対し、
-- nvim-lint はコードの問題検出（lint）を担当する。
--
-- 有効化済みのリンター:
--   Python     → flake8       (pip install flake8)
--   Go         → golangci-lint (brew install golangci-lint)
--   Lua        → luacheck      (brew install luacheck)
--   JS / TS    → eslint_d      (npm install -g eslint_d)  ← デーモン版で高速
--
-- コメントアウトで無効化しているもの（要インストール）:
--   PHP        → phpcs         (composer global require squizlabs/php_codesniffer)
--   HTML       → htmlhint      (npm install -g htmlhint)
--   CSS / SCSS → stylelint     (npm install -g stylelint)
--
-- キーマップ:
--   <leader>cl → 現在のファイルを手動で lint 実行
-- =============================================================================

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost" }, -- ファイル読み込み・保存後に起動

  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python          = { "flake8" },
      go              = { "golangcilint" },
      lua             = { "luacheck" },
      -- PHP（phpcs が必要: composer global require squizlabs/php_codesniffer）
      -- php = { "phpcs" },
      javascript      = { "eslint_d" }, -- eslint_d はデーモンとして常駐するため高速
      javascriptreact = { "eslint_d" },
      typescript      = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      -- HTML / CSS（コメントを外してインストール後に有効化）
      -- html = { "htmlhint" },  -- npm install -g htmlhint
      -- css  = { "stylelint" }, -- npm install -g stylelint
      -- scss = { "stylelint" },
    }

    -- 保存時・読み込み時・インサートモード離脱時に自動 lint
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      callback = function()
        lint.try_lint()
      end,
    })

    -- 手動 lint 実行
    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "Lint: 現在のファイルを lint" })
  end,
}
