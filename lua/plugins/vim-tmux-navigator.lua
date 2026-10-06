-- vim-tmux-navigator
-- nvim のスプリットと tmux のペインを Ctrl+H/J/K/L でシームレスに移動する
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "左のペイン/スプリットへ移動" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "下のペイン/スプリットへ移動" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "上のペイン/スプリットへ移動" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "右のペイン/スプリットへ移動" },
  },
}
