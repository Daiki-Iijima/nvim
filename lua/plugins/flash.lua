-- flash.nvim: ラベル付き高速ジャンプ
-- s は全モード vim default のまま (normal/visual = 文字削除して insert, operator = c の別名)。
-- S: 高速ジャンプ (2文字 + ラベル)
-- R: visual/operator で treesitter 検索
-- <c-s> (検索中): / 検索にラベル追加
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "S", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
