-- crates.nvim: Cargo.toml の依存関係管理
-- バージョン情報のインライン表示・アップデート・機能フラグ補完など
--
-- 主なキーマップ（Cargo.toml を開いたときに有効）:
--   <leader>ct  -- crates の情報を表示
--   <leader>cu  -- カーソル下のクレートをアップデート
--   <leader>cU  -- 全クレートをアップデート
--   <leader>ca  -- クレートの機能フラグを有効化
--   <leader>cA  -- 全クレートの機能フラグを有効化
--   <leader>cx  -- 使っていない機能フラグを削除
--   <leader>ce  -- crates.io のページを開く
--   <leader>ci  -- クレート情報のポップアップ

return {
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = true },
      },
      lsp = {
        enabled    = true,
        actions    = true,
        completion = true,
        hover      = true,
      },
    },
    config = function(_, opts)
      local crates = require("crates")
      crates.setup(opts)

      -- Cargo.toml 専用キーマップ
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "<leader>ct", crates.toggle,              vim.tbl_extend("force", o, { desc = "Crates: 表示切替" }))
          vim.keymap.set("n", "<leader>cu", crates.update_crate,        vim.tbl_extend("force", o, { desc = "Crates: クレートを更新" }))
          vim.keymap.set("n", "<leader>cU", crates.update_all_crates,   vim.tbl_extend("force", o, { desc = "Crates: 全クレートを更新" }))
          vim.keymap.set("n", "<leader>ca", crates.enable_feature,      vim.tbl_extend("force", o, { desc = "Crates: 機能フラグを有効化" }))
          vim.keymap.set("n", "<leader>cx", crates.disable_feature,     vim.tbl_extend("force", o, { desc = "Crates: 機能フラグを無効化" }))
          vim.keymap.set("n", "<leader>ce", crates.open_crates_io,      vim.tbl_extend("force", o, { desc = "Crates: crates.io を開く" }))
          vim.keymap.set("n", "<leader>ci", crates.show_crate_popup,    vim.tbl_extend("force", o, { desc = "Crates: クレート情報" }))
          vim.keymap.set("n", "<leader>cf", crates.show_features_popup, vim.tbl_extend("force", o, { desc = "Crates: 機能フラグ一覧" }))
        end,
      })
    end,
  },
}
