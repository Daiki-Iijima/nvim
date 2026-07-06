return {
  "CRAG666/code_runner.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("code_runner").setup({
      mode = "float",      -- フローティングウィンドウに出力
      focus = true,        -- 実行後フロートにフォーカス
      startinsert = false, -- インサートモードには入らない
      float = {
        border = "rounded",
      },
      filetype = {
        swift      = "swift",
        lua        = "lua",
        python     = "python3 -u",
        go         = "go run",
        cs         = "dotnet run",
        rust       = "cargo run",
        php        = "php",
        javascript = "node",
        typescript = "npx tsx",
      },
    })

    vim.keymap.set("n", "<leader>x", "<cmd>RunCode<cr>",
      { silent = true, desc = "コードを実行" })

    vim.keymap.set("n", "<leader>X", function()
      vim.ui.input({ prompt = "実行引数: " }, function(args)
        if args == nil then return end
        vim.cmd("RunCode " .. args)
      end)
    end, { silent = true, desc = "引数を指定してコードを実行" })
  end,
}
