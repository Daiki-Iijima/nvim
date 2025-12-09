return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false, -- 早めに読み込んで vim.ui.* とかを乗っ取る
  ---@type snacks.Config
  opts = {
    -- ==== Snacks モジュール有効化 ====
    picker = {
      enabled = true, -- FZF / Telescope 代わり
      -- ★ Explorer の picker に対してだけ list のキーを上書き
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                -- Explorer のリスト内で <C-n> → エクスプローラを閉じる
                ["<C-n>"] = { "cancel", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
    input = { enabled = true },     -- LSP rename の入力 UI がキレイになる
    indent = { enabled = true },    -- インデント可視化（hlchunk の代わり候補）
    notifier = { enabled = true },  -- 通知 UI
    quickfile = { enabled = true }, -- `nvim file` が速くなる
    lazygit = { enabled = true },   -- lazygit フロート
    rename = { enabled = true },    -- ファイルリネーム + LSP 連携
    terminal = { enabled = true },  -- ターミナル表示

    -- Explorer 本体の設定（こっちは「モジュール」用）
    explorer = {
      enabled = true,
      replace_netrw = true, -- nvim . で自動起動したいなら
    },
  },

  config = function(_, opts)
    local Snacks = require("snacks")
    Snacks.setup(opts)

    local map = vim.keymap.set

    -- ===== Picker =====
    map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
    map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live Grep" })
    map("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent Files" })
    map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
    map("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Help" })
    map("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })

    -- ===== LSP =====
    map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP Rename" })
    map("n", "<leader>ld", Snacks.picker.lsp_definitions, { desc = "LSP Definitions" })
    map("n", "<leader>lR", Snacks.picker.lsp_references, { desc = "LSP References" })
    map("n", "<leader>li", Snacks.picker.lsp_implementations, { desc = "LSP Implementations" })

    -- ===== Git =====
    map("n", "<leader>lg", function()
      Snacks.lazygit()
    end, { desc = "LazyGit (Snacks)" })

    -- ===== Explorer (toggle) =====
    -- 通常バッファではこれが効く
    map("n", "<C-n>", function()
      Snacks.explorer()
    end, { desc = "Toggle Explorer (Snacks)" })

    -- ===== Terminal =====
    map({ "n", "t" }, "<C-/>", function()
      Snacks.terminal()
    end, { desc = "Toggle Terminal (Snacks)" })
  end,
}
