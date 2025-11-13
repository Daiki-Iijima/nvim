return {
  "jbyuki/venn.nvim",

  -- markdown を開いたときだけ読み込む
  ft = { "markdown" },

  config = function()
    -- グローバル関数としてトグル定義（中身はバッファローカルフラグを見る）
    function _G.Toggle_venn()
      local enabled = vim.b.venn_enabled

      if not enabled then
        print("Enabling venn mode")
        vim.b.venn_enabled = true
        vim.cmd([[setlocal ve=all]])

        -- 線／矢印のショートカット（このバッファだけ）
        vim.keymap.set("n", "J", "<C-v>j:VBox<CR>", { buffer = true, noremap = true })
        vim.keymap.set("n", "K", "<C-v>k:VBox<CR>", { buffer = true, noremap = true })
        vim.keymap.set("n", "L", "<C-v>l:VBox<CR>", { buffer = true, noremap = true })
        vim.keymap.set("n", "H", "<C-v>h:VBox<CR>", { buffer = true, noremap = true })

        -- 必要ならここで見た目調整もできる（今は何もしなくてもOK）
        -- pcall(vim.cmd, "DisableHLIndent")
      else
        print("Disabling venn mode")
        vim.b.venn_enabled = nil
        vim.cmd([[setlocal ve=]])

        vim.keymap.del("n", "J", { buffer = true })
        vim.keymap.del("n", "K", { buffer = true })
        vim.keymap.del("n", "L", { buffer = true })
        vim.keymap.del("n", "H", { buffer = true })

        -- pcall(vim.cmd, "EnableHLIndent")
      end
    end

    -- markdown バッファが開かれたときにだけキーマップを張る
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        local bufnr = ev.buf

        -- venn モード ON/OFF（この markdown バッファだけ）
        vim.keymap.set(
          "n",
          "<leader>v",
          Toggle_venn,
          { buffer = bufnr, noremap = true, silent = true }
        )

        -- ビジュアルブロック中に Ctrl+b で Box 作成（これも markdown だけ）
        vim.keymap.set(
          "v",
          "<C-b>",
          ":VBox<CR>",
          { buffer = bufnr, noremap = true }
        )
      end,
    })
  end,
}

