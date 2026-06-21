-- =============================================================================
-- todo-comments.nvim: TODOコメントのハイライトと横断検索
-- =============================================================================
-- コード内の TODO, FIXME, NOTE などのコメントを美しく強調表示し、
-- snacks.nvim の picker を使ってプロジェクト全体から検索できるようにします。
-- =============================================================================

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  opts = {},
  keys = {
    {
      "<leader>ft",
      function()
        Snacks.picker.todo_comments()
      end,
      desc = "TODOコメントを横断検索",
    },
  },
}
