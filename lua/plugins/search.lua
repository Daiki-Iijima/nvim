return {
  {
    "haya14busa/vim-asterisk",
    config = function()
      -- キーマッピングは nvim-hlslens 側と連携して定義します
    end,
  },
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("hlslens").setup({
        calm_down = true,     -- カーソル移動やインサートモードに入った時に自動でハイライトをクリアする
        nearest_only = true,  -- カーソル位置のインデックス表示をスマートにする
      })

      local opts = { silent = true }

      -- vim-asterisk と nvim-hlslens を連携させたキーマッピング
      -- * や # を押した時に「カーソルをジャンプさせずにその場をハイライト」します
      vim.keymap.set({ "n", "x" }, "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.keymap.set({ "n", "x" }, "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.keymap.set({ "n", "x" }, "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.keymap.set({ "n", "x" }, "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], opts)

      -- n / N キーで移動する際にも hlslens を連動させてインデックス（[3/12] など）を表示
      vim.keymap.set("n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
      vim.keymap.set("n", "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], opts)

      -- Escキーを2回押した時に検索ハイライトを消去する
      vim.keymap.set("n", "<Esc><Esc>", "<Cmd>noh<CR>", opts)
    end,
  },
}
