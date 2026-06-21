-- =============================================================================
-- trouble.nvim: 警告・エラー・LSP情報の美しすぎるツリー表示
-- =============================================================================
-- プロジェクト内のエラーや警告、LSPによるシンボル情報、参照一覧などを
-- VS Codeのような見やすい専用バッファ（ツリー形式）で開閉できるようにします。
-- =============================================================================

return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {},
  keys = {
    {
      "<leader>tt",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Trouble: プロジェクト全体の警告/エラー表示",
    },
    {
      "<leader>td",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Trouble: 現在のファイルの警告/エラー表示",
    },
    {
      "<leader>ts",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Trouble: シンボル一覧をトグル",
    },
    {
      "<leader>tr",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "Trouble: LSP定義/参照一覧をトグル",
    },
    {
      "<leader>tq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Trouble: Quickfix一覧を表示",
    },
  },
}
