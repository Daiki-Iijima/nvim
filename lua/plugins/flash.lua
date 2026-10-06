-- flash.nvim: 画面内の任意の場所に瞬間移動
-- s + 2文字 でラベルが出て、そのキーを押すとそこへジャンプ
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash ジャンプ" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter 選択" },
  },
}
