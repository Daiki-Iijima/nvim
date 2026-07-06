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

    -- ===== Toggles (on/off) =====
    Snacks.toggle.option("spell", { name = "スペルチェック" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "行の折り返し" }):map("<leader>uw")
    Snacks.toggle.option("relativenumber", { name = "相対行番号" }):map("<leader>uL")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.inlay_hints():map("<leader>uh")
  end,
}
