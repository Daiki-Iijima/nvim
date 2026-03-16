return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "▁" },
      topdelete    = { text = "▔" },
      changedelete = { text = "▎" },
      untracked    = { text = "▎" },
    },
    current_line_blame = false, -- <leader>gb でトグル
  },
  config = function(_, opts)
    local gs = require("gitsigns")
    gs.setup(opts)

    local map = vim.keymap.set

    -- hunk ナビゲーション
    map("n", "]g", function() gs.nav_hunk("next") end, { desc = "次の変更箇所へ" })
    map("n", "[g", function() gs.nav_hunk("prev") end, { desc = "前の変更箇所へ" })

    -- hunk 操作
    map("n", "<leader>gs", gs.stage_hunk,   { desc = "Git: hunk をステージ" })
    map("n", "<leader>gr", gs.reset_hunk,   { desc = "Git: hunk をリセット" })
    map("n", "<leader>gS", gs.stage_buffer, { desc = "Git: バッファ全体をステージ" })
    map("n", "<leader>gR", gs.reset_buffer, { desc = "Git: バッファ全体をリセット" })
    map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Git: ステージを取り消し" })

    -- 情報表示
    map("n", "<leader>gp", gs.preview_hunk, { desc = "Git: hunk の差分をプレビュー" })
    map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git: 行の blame を表示" })
    map("n", "<leader>gB", gs.toggle_current_line_blame, { desc = "Git: インライン blame をトグル" })
    map("n", "<leader>gd", gs.diffthis,     { desc = "Git: diff を表示" })
  end,
}
