-- =============================================================================
-- vim-tmux-navigator: Vim ↔ Tmux のシームレスなウィンドウ移動
-- =============================================================================
-- tmux.conf 側の設定と連動し、Ctrl + h/j/k/l を使うことで、
-- Neovim の分割画面（スプリット）と Tmux のペインの間を
-- 境界線を意識することなくシームレスに行き来できるようにします。
-- =============================================================================

return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Tmux/Window: 左のペイン/分割へ" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Tmux/Window: 下のペイン/分割へ" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Tmux/Window: 上のペイン/分割へ" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>",   desc = "Tmux/Window: 右のペイン/分割へ" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Tmux/Window: 前のペイン/分割へ" },
  },
}
