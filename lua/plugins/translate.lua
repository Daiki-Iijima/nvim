-- translate.nvim: キーは張らない。コマンドパレット（<leader>:）か直接打つ:
--   :Translate JA                 選択範囲 or カーソル単語を日本語に（ビジュアルなら :'<,'>Translate JA）
--   :Translate JA -output=insert  翻訳結果をカーソル下に挿入
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
  end,
}
