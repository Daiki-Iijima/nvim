return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.9",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
  },

  keys = {
    -- 🔍 ファイル検索
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },

    -- 🔥 ripgrep で全文検索
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },

    -- 📚 最近使ったファイル
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent Files" },

    -- 🧭 カーソル位置の関数やクラス
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },

    -- 🔎 Neovim のヘルプ検索
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
  },

  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        layout_strategy = "flex",
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
      },
    })

    -- fzf 高速化拡張
    pcall(telescope.load_extension, "fzf")
  end,
}

