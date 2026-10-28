return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false, -- 早めに読み込んで vim.ui.* とかを乗っ取る
  ---@type snacks.Config
  opts = {
    -- ==== Snacks モジュール有効化 ====
    picker = {
      enabled = true, -- FZF / Telescope 代わり
      ui_select = true, -- vim.ui.select を Snacks.picker.select に置き換える
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
          transform = function(item, ctx)
            local translations = {
              -- nvim-surround
              ["Change a surrounding pair"] = "囲み(surround)を変更する",
              ["Delete a surrounding pair"] = "囲み(surround)を削除する",
              ["Add a surrounding pair around a motion (normal mode)"] = "モーションの周囲に囲み(surround)を追加 (ノーマルモード)",
              ["Add a surrounding pair around the cursor (insert mode)"] = "カーソルの周囲に囲み(surround)を追加 (インサートモード)",
              ["Change a surrounding pair, putting replacements on new lines"] = "囲み(surround)を変更し、改行して配置する",
              ["Add a surrounding pair around the current line (normal mode)"] = "現在の行の周囲に囲み(surround)を追加 (ノーマルモード)",
              ["Add a surrounding pair around a visual selection, on new lines"] = "ビジュアル選択範囲を改行して囲み(surround)を追加",
              ["Add a surrounding pair around a motion, on new lines (normal mode)"] = "モーションの周囲に改行して囲み(surround)を追加 (ノーマルモード)",
              ["Add a surrounding pair around the cursor, on new lines (insert mode)"] = "カーソルの周囲に改行して囲み(surround)を追加 (インサートモード)",
              ["Add a surrounding pair around the current line, on new lines (normal mode)"] = "現在の行の周囲に改行して囲み(surround)を追加 (ノーマルモード)",
              ["Add a surrounding pair around a visual selection"] = "ビジュアル選択範囲を囲む(surround)",

              -- flash.nvim
              ["Flash Jump"] = "Flashジャンプ (高速移動)",
              ["Treesitter Search"] = "Treesitter検索 (構文選択)",
              ["Toggle Flash Search"] = "Flash検索トグル",
            }

            local desc = item.item.desc
            if desc and desc ~= "" then
              local trans = translations[desc]
              if not trans then
                -- Fallback translation patterns for surrounding keymaps
                if desc:lower():find("surround") then
                  trans = desc
                  trans = trans:gsub("[Cc]hange a surrounding pair", "囲み(surround)を変更")
                  trans = trans:gsub("[Dd]elete a surrounding pair", "囲み(surround)を削除")
                  trans = trans:gsub("[Aa]dd a surrounding pair", "囲み(surround)を追加")
                  trans = trans:gsub("around a motion", "モーションの周囲に")
                  trans = trans:gsub("around the cursor", "カーソルの周囲に")
                  trans = trans:gsub("around the current line", "現在の行の周囲に")
                  trans = trans:gsub("around a visual selection", "ビジュアル選択範囲の周囲に")
                  trans = trans:gsub("on new lines", "改行して")
                  trans = trans:gsub("normal mode", "ノーマル")
                  trans = trans:gsub("insert mode", "挿入")
                  trans = trans:gsub("putting replacements", "置き換えて")
                  if not trans:find("囲") then
                    trans = trans .. " [囲む/surround]"
                  end
                end
              end

              if trans then
                item.item.desc = trans
                -- Update item.text so matching works on the translation and keywords
                item.text = item.text .. " " .. trans .. " 囲む surround"
              end
            else
              -- If no desc, check if RHS contains surround or similar to add keywords
              local rhs = item.item.rhs or ""
              if rhs:lower():find("surround") or item.item.lhs:lower():find("surround") then
                item.text = item.text .. " 囲む surround"
              end
            end
            return item
          end,
        },
      },
    },
    scratch = { -- そのディレクトリで使えるメモ？
      enabled = true,
      filekey = { cwd = false, branch = false, count = false },
      ft = "markdown",
    },
    input = { enabled = true },     -- LSP rename の入力 UI がキレイになる
    indent = { enabled = true, char = "│" },    -- インデント可視化
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

    -- ==== 追加の便利モジュール ====
    bigfile = { enabled = true },   -- 超巨大ファイルを開いた時の動作軽量化
    scroll = { enabled = true },    -- 物理アニメーションによるヌルヌルスクロール
    words = { enabled = true },     -- 同一単語（変数など）の自動ハイライトと [[ / ]] での移動
    dashboard = { enabled = true }, -- Neovim 起動時の美麗ダッシュボード
  },

  config = function(_, opts)
    local Snacks = require("snacks")
    Snacks.setup(opts)

    local map = vim.keymap.set

    -- 入口は 3 つ: 探す（<leader><space> / <leader>/ / <leader>f*）・コードの操作（Neovim 既定の gr* / K / [d ]d）・
    -- それ以外はコマンドパレット（<leader>: コマンド一覧 / <leader>? キー一覧）。早見表は :Cheatsheet

    -- ===== 探す =====
    map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "探す: ファイル（最近・バッファ優先）" })
    map("n", "<leader>/", function() Snacks.picker.grep() end,          { desc = "探す: 文字列（プロジェクト全体）" })
    map("n", "<leader>ff", function() Snacks.picker.files() end,   { desc = "ファイル" })
    map("n", "<leader>fg", function() Snacks.picker.grep() end,    { desc = "文字列（grep）" })
    map("n", "<leader>fr", function() Snacks.picker.recent() end,  { desc = "最近のファイル" })
    map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "バッファ" })
    map("n", "<leader>fh", function() Snacks.picker.help() end,    { desc = "ヘルプ" })
    map("n", "<leader>fd", function() Snacks.picker.diagnostics() end,        { desc = "診断（プロジェクト全体）" })
    map("n", "<leader>fD", function() Snacks.picker.diagnostics_buffer() end, { desc = "診断（このファイル）" })
    map("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end,        { desc = "シンボル" })
    map("n", "<leader>fq", function() Snacks.picker.qflist() end,             { desc = "Quickfix" })

    -- ===== コマンドパレット（めったに使わないものはここから呼ぶ）=====
    map("n", "<leader>:", function() Snacks.picker.commands() end, { desc = "コマンドパレット" })
    map("n", "<leader>?", function() Snacks.picker.keymaps() end,  { desc = "キー一覧" })
    vim.api.nvim_create_user_command("Scratch", function() Snacks.scratch() end, { desc = "スクラッチファイルを開く" })

    -- 早見表: README.md の <!-- cheatsheet:start --> 〜 <!-- cheatsheet:end --> を浮いた窓で出す（表は README の 1 か所だけ）
    vim.api.nvim_create_user_command("Cheatsheet", function()
      local lines = vim.fn.readfile(vim.fn.stdpath("config") .. "/README.md")
      local s = vim.fn.index(lines, "<!-- cheatsheet:start -->")
      local e = vim.fn.index(lines, "<!-- cheatsheet:end -->")
      Snacks.win({
        text = vim.list_slice(lines, s + 2, e),
        ft = "markdown",
        width = 0.6,
        height = 0.8,
        border = "rounded",
        title = " 早見表（q で閉じる） ",
        bo = { modifiable = false },
        wo = { wrap = false, conceallevel = 2 },
      })
    end, { desc = "早見表（普段使うキー）" })

    -- ===== Git =====
    map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })

    -- ===== Explorer (toggle) =====
    map("n", "<C-n>", function()
      Snacks.explorer()
    end, { desc = "ファイルエクスプローラーを開閉" })

    -- ===== Terminal =====
    map({ "n", "t" }, "<C-/>", function()
      Snacks.terminal()
    end, { desc = "ターミナルを開閉" })

    -- ===== 切り替え（on/off）=====
    Snacks.toggle.option("spell", { name = "スペルチェック" }):map("<leader>ts")
    Snacks.toggle.option("wrap", { name = "行の折り返し" }):map("<leader>tw")
    Snacks.toggle.option("relativenumber", { name = "相対行番号" }):map("<leader>tn")
    Snacks.toggle.diagnostics():map("<leader>td")
    Snacks.toggle.inlay_hints():map("<leader>th")
  end,
}
