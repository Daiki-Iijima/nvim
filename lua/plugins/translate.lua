return {
  "uga-rosa/translate.nvim",
  cmd = "Translate",
  config = function()
    require("translate").setup({
      default = {
        command = "google",   -- API キー不要
        output = "floating",  -- フロートウィンドウで表示
      },
      preset = {
        output = {
          floating = {
            border = "rounded",  -- 他のポップアップと統一
          },
        },
      },
    })

    local map = vim.keymap.set

    -- <leader>t : 選択範囲 or カーソル単語を日本語に翻訳
    map({ "n", "v" }, "<leader>t", function()
      vim.cmd("Translate JA")
    end, { desc = "翻訳（日本語）" })

    -- <leader>T : 翻訳結果をカーソル下に挿入
    map({ "n", "v" }, "<leader>T", function()
      vim.cmd("Translate JA -output=insert")
    end, { desc = "翻訳して挿入" })
  end,
}
