-- venn.nvim: 線で図を描く。キーは張らない。コマンドパレット（<leader>:）か :VennToggle で切り替える。
-- 描くモード中だけ（このバッファ）: H/J/K/L で線を引く・ビジュアルブロックで <C-b> 箱を描く
return {
  "jbyuki/venn.nvim",
  cmd = { "VennToggle", "VBox" },

  config = function()
    local keys = { H = "h", J = "j", K = "k", L = "l" }
    vim.api.nvim_create_user_command("VennToggle", function()
      if not vim.b.venn_enabled then
        vim.b.venn_enabled = true
        vim.cmd([[setlocal ve=all]])
        for lhs, dir in pairs(keys) do
          vim.keymap.set("n", lhs, "<C-v>" .. dir .. ":VBox<CR>", { buffer = true })
        end
        vim.keymap.set("v", "<C-b>", ":VBox<CR>", { buffer = true })
        print("venn: 描くモード ON")
      else
        vim.b.venn_enabled = nil
        vim.cmd([[setlocal ve=]])
        for lhs in pairs(keys) do
          vim.keymap.del("n", lhs, { buffer = true })
        end
        vim.keymap.del("v", "<C-b>", { buffer = true })
        print("venn: 描くモード OFF")
      end
    end, { desc = "venn: 線で図を描くモードの切り替え" })
  end,
}
