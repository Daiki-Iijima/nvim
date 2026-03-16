return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false, -- 早めに読み込んで vim.ui.* とかを乗っ取る
  ---@type snacks.Config
  opts = {
    -- ==== Snacks モジュール有効化 ====
    picker = {
      enabled = true, -- FZF / Telescope 代わり
      -- Explorer の picker に対してだけ list のキーを上書き
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
        keymaps = {
          layout = { preview = false }, -- キーマップ一覧はプレビュー不要
        },
      },
    },
    scratch = { -- そのディレクトリで使えるメモ？
      enabled = true,
      filekey = { cwd = false, branch = false, count = false },
      ft = "markdown",
    },
    input = { enabled = true },     -- LSP rename の入力 UI がキレイになる
    indent = { enabled = true },    -- インデント可視化（hlchunk の代わり候補）
    notifier = { enabled = true },  -- 通知 UI
    quickfile = { enabled = true }, -- `nvim file` が速くなる
    lazygit = { enabled = true },   -- lazygit フロート
    rename = { enabled = true },    -- ファイルリネーム + LSP 連携
    terminal = {
      enabled = true,
      win = {
        style = "terminal",
        keys = {
          -- Esc 1回でノーマルモード（コピーモード）に入る
          term_normal = {
            "<esc>",
            "<C-\\><C-n>",
            mode = "t",
            desc = "Esc でノーマルモードへ",
          },
        },
      },
    },

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
    map("n", "<leader>ff", function() Snacks.picker.files() end,   { desc = "ファイルを検索して開く" })
    map("n", "<leader>fg", function() Snacks.picker.grep() end,    { desc = "ファイル内の文字列を横断検索" })
    map("n", "<leader>fr", function() Snacks.picker.recent() end,  { desc = "最近開いたファイルを表示" })
    map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "開いているバッファ一覧" })
    map("n", "<leader>fh", function() Snacks.picker.help() end,    { desc = "ヘルプを検索" })
    map("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "キーマップ一覧を表示" })

    -- ===== Scratch ====
    map("n", "<leader>S", function() Snacks.scratch() end, { desc = "スクラッチファイルを開く" })

    -- ===== LSP =====
    map("n", "<leader>lr", vim.lsp.buf.rename,              { desc = "LSP: シンボルをリネーム" })
    map("n", "<leader>ld", Snacks.picker.lsp_definitions,   { desc = "LSP: 定義へジャンプ (Picker)" })
    map("n", "<leader>lR", Snacks.picker.lsp_references,    { desc = "LSP: 参照一覧 (Picker)" })
    map("n", "<leader>li", Snacks.picker.lsp_implementations, { desc = "LSP: 実装一覧 (Picker)" })

    -- ===== Git =====
    map("n", "<leader>lg", function()
      Snacks.lazygit()
    end, { desc = "LazyGit を開く" })

    -- ===== Explorer (toggle) =====
    map("n", "<C-n>", function()
      Snacks.explorer()
    end, { desc = "ファイルエクスプローラーを開閉" })

    -- ===== Terminal =====
    map({ "n", "t" }, "<C-/>", function()
      Snacks.terminal()
    end, { desc = "ターミナルを開閉" })
  end,
}
