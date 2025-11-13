return {
  "tpope/vim-commentary",
  event = "VeryLazy",
  config = function()
    -- VSCode みたいな Ctrl + / コメント切り替え
    vim.keymap.set("n", "<C-_>", "gcc", { noremap = true, silent = true })
    vim.keymap.set("v", "<C-_>", "gc",  { noremap = true, silent = true })
  end,
}
