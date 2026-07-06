-- =============================================================================
-- vim-zellij-navigator: Neovim ↔ Zellij のシームレスなウィンドウ移動
-- =============================================================================
-- Zellij 側の設定と連動し、Ctrl + h/j/k/l を使うことで、
-- Neovim の分割画面（スプリット）と Zellij のペインの間を
-- 境界線を意識することなくシームレスに行き来できるようにします。
-- =============================================================================

return {
  "hiasr/vim-zellij-navigator.nvim",
  keys = {
    { "<C-h>", "<cmd>NavigateLeft<cr>",  desc = "Zellij/Window: 左のペイン/分割へ" },
    { "<C-j>", "<cmd>NavigateDown<cr>",  desc = "Zellij/Window: 下のペイン/分割へ" },
    { "<C-k>", "<cmd>NavigateUp<cr>",    desc = "Zellij/Window: 上のペイン/分割へ" },
    { "<C-l>", "<cmd>NavigateRight<cr>",   desc = "Zellij/Window: 右のペイン/分割へ" },
  },
  config = function()
    require("vim-zellij-navigator").setup()
  end,
}
