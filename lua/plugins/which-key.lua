-- which-key.nvim: キーマップ一覧をポップアップ表示
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 500, -- ms 押し続けたらポップアップ表示
    icons = { mappings = true },
    spec = {
      -- グループ名を登録しておくとポップアップが見やすくなる
      { "<leader>f", group = "ファイル検索" },
      { "<leader>l", group = "LSP" },
      { "<leader>b", group = "バッファ" },
    },
  },
}
