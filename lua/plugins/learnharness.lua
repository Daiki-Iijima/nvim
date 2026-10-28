-- LearnHarness Plus のコードの問題を nvim で書くプラグイン（このファイルを消して :Lazy clean で外せます）
-- 説明: ~/ghq/github.com/Daiki-Iijima/learnharness/editors/nvim/learnharness.nvim/README.md
return {
  dir = "~/ghq/github.com/Daiki-Iijima/learnharness/editors/nvim/learnharness.nvim",
  event = "VeryLazy",
  cmd = "LH",
  opts = {},
  keys = {
    { "<localleader>t", "<cmd>LH test<cr>", desc = "LH: テスト" },
    { "<localleader>h", "<cmd>LH hint<cr>", desc = "LH: ヒント" },
    { "<localleader>s", "<cmd>LH submit<cr>", desc = "LH: 提出" },
    { "<localleader>o", "<cmd>LH open<cr>", desc = "LH: アプリで開く" },
    { "<localleader>n", "<cmd>LH next<cr>", desc = "LH: 次の問題" },
    { "<localleader>d", "<cmd>LH solution<cr>", desc = "LH: 模範解答と比べる" },
    { "<A-j>", function() vim.cmd("LH move down " .. vim.v.count1) end, desc = "LH: 行を下へ" },
    { "<A-k>", function() vim.cmd("LH move up " .. vim.v.count1) end, desc = "LH: 行を上へ" },
    { "<A-j>", ":LH move down<cr>gv", mode = "x", desc = "LH: 範囲を下へ" },
    { "<A-k>", ":LH move up<cr>gv", mode = "x", desc = "LH: 範囲を上へ" },
  },
}
