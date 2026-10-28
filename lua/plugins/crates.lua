-- crates.nvim: Cargo.toml の依存関係管理
-- バージョン情報のインライン表示・アップデート・機能フラグ補完など
--
-- キーは張らない。コマンドパレット（<leader>:）から :Crates <サブコマンド> で呼ぶ:
--   :Crates toggle / update_crate / update_all_crates / enable_feature / disable_feature
--   :Crates open_cratesio / show_crate_popup / show_features_popup（機能フラグなどはコードアクション gra でも出る）

return {
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    cmd = "Crates",
    opts = {
      completion = {
        cmp = { enabled = false }, -- 補完は下の in-process LSP 経由で blink.cmp に出る
      },
      lsp = {
        enabled    = true,
        actions    = true,
        completion = true,
        hover      = true,
      },
    },
  },
}
