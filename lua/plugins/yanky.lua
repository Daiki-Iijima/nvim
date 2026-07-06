return {
  "gbprod/yanky.nvim",
  event = "VeryLazy",
  opts = {
    ring = {
      history_length = 100, -- 履歴を100個保持
      storage = "shada",    -- Neovimを閉じても履歴を保存
      sync_with_numbered_registers = true,
    },
    system_clipboard = {
      sync_with_ring = true, -- システムのクリップボードと同期
    },
  },
  keys = {
    -- 通常のペーストを Yanky の高機能ペーストに置き換え（自動インデント調整などが効くようになります）
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "ペースト（後）" },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "ペースト（前）" },
    { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "ペースト（カーソルを末尾へ）" },
    { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "ペースト（カーソルを末尾へ・前）" },

    -- ペースト直後に履歴を前後に切り替える（<C-n> / <C-p> の競合を避けるため [y / ]y に変更）
    { "[y", "<Plug>(YankyCycleForward)", desc = "ヤンク履歴を前に戻す" },
    { "]y", "<Plug>(YankyCycleBackward)", desc = "ヤンク履歴を先に進める" },

    -- snacks.picker でヤンク履歴を一覧検索する
    { "<leader>fy", "<cmd>YankyRingHistory<cr>", desc = "ヤンク履歴を検索" },
  },
}
