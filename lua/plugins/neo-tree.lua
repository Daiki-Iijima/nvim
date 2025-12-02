return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- Nerd Font 必須
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true, -- 最後のウィンドウなら自動で閉じる
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      hide_dotfiles = false,
      sort_case_insensitive = true,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules" },
        },
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
      },
      window = {
        width = 30,
        mappings = {
          ["<space>"] = "none", -- スペース無効化（誤爆防止）
          -- ⬅️ 狭くする
          ["<C-h>"] = {
            function(state)
              vim.cmd("vertical resize -5")
            end,
            desc = "Shrink Neo-tree window",
          },

          -- ➡️ 広げる
          ["<C-l>"] = {
            function(state)
              vim.cmd("vertical resize +5")
            end,
            desc = "Expand Neo-tree window",
          },
        },
      },
    })

    -- キーマップ
    vim.keymap.set("n", "<C-n>", ":Neotree toggle left<CR>", { desc = "Toggle NeoTree" })
    vim.keymap.set("n", "<C-o>", ":Neotree reveal<CR>", { desc = "Reveal current file" })
  end,
}
