-- スニペットの動的変数（LSP変数）を解決するヘルパー関数
local function get_snippet_var_value(var_name)
  if var_name == "CURRENT_YEAR" then return os.date("%Y")
  elseif var_name == "CURRENT_YEAR_SHORT" then return os.date("%y")
  elseif var_name == "CURRENT_MONTH" then return os.date("%m")
  elseif var_name == "CURRENT_MONTH_NAME" then return os.date("%B")
  elseif var_name == "CURRENT_MONTH_NAME_SHORT" then return os.date("%b")
  elseif var_name == "CURRENT_DATE" then return os.date("%d")
  elseif var_name == "CURRENT_DAY_NAME" then return os.date("%A")
  elseif var_name == "CURRENT_DAY_NAME_SHORT" then return os.date("%a")
  elseif var_name == "CURRENT_HOUR" then return os.date("%H")
  elseif var_name == "CURRENT_MINUTE" then return os.date("%M")
  elseif var_name == "CURRENT_SECOND" then return os.date("%S")
  elseif var_name == "CURRENT_SECONDS_UNIX" then return tostring(os.time())
  elseif var_name == "TM_FILENAME" then return vim.fn.expand("%:t")
  elseif var_name == "TM_FILENAME_BASE" then return vim.fn.expand("%:t:r")
  elseif var_name == "TM_DIRECTORY" then return vim.fn.expand("%:p:h:t")
  elseif var_name == "TM_FILEPATH" then return vim.fn.expand("%:p")
  elseif var_name == "CLIPBOARD" then
    local clip = vim.fn.getreg("+")
    if not clip or clip == "" then clip = vim.fn.getreg('"') end
    return clip or ""
  end
  return nil
end

local function resolve_snippet_vars(text)
  if not text or type(text) ~= "string" then return text end

  -- ${VAR_NAME} または ${VAR_NAME:default} を置換
  text = text:gsub("%%${([%%w_]+)([^}]*)}", function(var_name, suffix)
    local val = get_snippet_var_value(var_name)
    if val then
      return val
    elseif suffix:sub(1, 1) == ":" then
      return suffix:sub(2) -- デフォルト値を返す
    end
    return nil -- 置換しない
  end)

  -- $VAR_NAME を置換 (ただし $1 や $0 などのタブストップは除外するために英字またはアンダースコア開始に限定)
  text = text:gsub("%%$([a-zA-Z_][%%w_]*)", function(var_name)
    return get_snippet_var_value(var_name)
  end)

  return text
end

return {

  --------------------------------------------------------------------
  -- nvim-lspconfig: LSP クライアントの起動管理
  -- -------------------------------------------------------------------
  -- Neovim 組み込みの LSP クライアント（vim.lsp）を各言語サーバーに接続する。
  -- 実際の言語ごとの設定は lua/lang/ 以下の各ファイルに分散させており、
  -- ここでは lang/_loader.setup() を呼ぶだけ。
  -- -------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- ファイルを開いたタイミングで起動
    config = function()
      require("lang._loader").setup()
    end,
  },

  --------------------------------------------------------------------
  -- blink.cmp: 超高速な Rust 製補完エンジン
  -- -------------------------------------------------------------------
  -- 入力中に候補をポップアップ表示する補完フレームワーク。
  -- Rust でビルドされており、非常に高速に動作する。
  -- 
  -- 補完ソースの優先度設定:
  --   1. lazydev   → Neovim API（Lua 編集時のみ最優先）
  --   2. lsp       → LSP サーバーからの補完
  --   3. path      → ファイルシステムのパス補完
  --   4. snippets  → スニペット候補 (friendly-snippets)
  --   5. buffer    → 開いているバッファ内の単語
  -- -------------------------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "1.*", -- 安定ビルド済みのバイナリをダウンロード
    -- 挿入モードだけでなく、コマンドラインに入ったタイミングでも起動するように拡張
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets", -- スニペット集（既存のものを流用）
      "L3MON4D3/LuaSnip",
    },
    opts = {
      -- キーマップ設定
      -- preset = "enter" で Enterでの確定を有効にしつつ、
      -- Tab/S-Tab で補完選択およびスニペットのジャンプ（プレースホルダ移動）ができるようにします。
      keymap = {
        preset = "enter",
        ["<CR>"] = { "fallback" },
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },

      -- nvim-cmp のハイライトグループをフォールバックとして使用
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },

      -- 引数ガイド（シグネチャヘルプ）を有効化
      signature = { enabled = true },
      -- スニペットエンジンとして LuaSnip を指定（デフォルトの vim.snippet は補完確定時にセッションが切れやすいため）
      snippets = { preset = "luasnip" },

      -- コマンドライン補完を有効化
      cmdline = {
        enabled = true,
        keymap = { preset = "cmdline" },
        sources = { "cmdline", "buffer" },
      },

      completion = {
        -- 補完ウィンドウのドキュメントを自動表示
        documentation = {
          auto_show = true,
          window = { border = "rounded" },
        },
        -- 補完ポップアップの表示項目（左に候補名、右にアイコン）
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 }, { "kind" } },
          },
        },
        -- 選択中の補完候補をバッファ上にゴーストテキストとしてプレビュー表示
        ghost_text = {
          enabled = true,
        },
      },

      -- 補完ソースの設定
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer", "codecompanion" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- Neovim APIの補完を最優先
          },
          codecompanion = {
            name = "CodeCompanion",
            module = "codecompanion.providers.completion.blink",
            enabled = true,
          },
          snippets = {
            score_offset = -3,  -- スニペットをリストの下部に押し下げる（既存のソート設定の再現）
            transform_items = function(ctx, items)
              for _, item in ipairs(items) do
                local label = item.label
                local date_str = nil
                if label == "date" or item.insertText == "date" then
                  date_str = os.date("%Y-%m-%d")
                elseif label == "time" or item.insertText == "time" then
                  date_str = os.date("%H:%M:%S")
                elseif label == "datetime" or item.insertText == "datetime" then
                  date_str = os.date("%Y-%m-%d %H:%M:%S")
                end

                if date_str then
                  item.insertText = date_str
                  if item.textEdit then item.textEdit.newText = date_str end
                else
                  -- それ以外のスニペットに存在するLSP変数（$CURRENT_YEARなど）を動的に解決
                  if item.insertText then
                    item.insertText = resolve_snippet_vars(item.insertText)
                  end
                  if item.textEdit and item.textEdit.newText then
                    item.textEdit.newText = resolve_snippet_vars(item.textEdit.newText)
                  end
                end
              end
              return items
            end,
          },
          buffer = {
            score_offset = -5,  -- バッファ内単語はさらに下に
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },

  --------------------------------------------------------------------
  -- nvim-treesitter: シンタックスハイライト / インデント
  -- -------------------------------------------------------------------
  -- 各言語の構文木（AST）をパースして、
  -- 正確なシンタックスハイライトとインデントを提供する。
  -- 正規表現ベースの従来ハイライトより精度が高く、ネストや複雑な構文に強い。
  --
  -- ensure_installed に言語名を追加すると自動でパーサーがインストールされる。
  -- `:TSInstall <言語>` で後から追加することも可能。
  -- -------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,           -- FileType autocmd を確実に登録するため eager に
    build = ":TSUpdate",    -- プラグイン更新時にパーサーも自動更新
    config = function()
      -- 言語のエイリアス登録 (markdown 内の ```js や ```ts などのコードブロックのハイライト用)
      vim.treesitter.language.register("javascript", "js")
      vim.treesitter.language.register("typescript", "ts")
      vim.treesitter.language.register("bash", "sh")
      vim.treesitter.language.register("html", "ejs")

      local parsers = {
        -- 設定ファイル系
        "lua", "vim", "vimdoc", "bash", "regex",
        -- マークアップ・スタイル
        "markdown", "markdown_inline",
        "html", "css", "scss",
        -- データ形式 (jsonc は main ブランチで未サポート → json で代用)
        "json", "yaml", "toml",
        -- Web フロントエンド
        "javascript", "typescript", "tsx",
        -- システム/ネイティブ言語
        "rust", "c", "cpp", "go", "c_sharp",
      }
      -- Swift は macOS でのみ (Linux だと tree-sitter CLI 互換性問題)
      if vim.fn.has("mac") == 1 then
        table.insert(parsers, "swift")
      end

      -- tree-sitter CLI 0.25+ は --no-bindings 廃止 (デフォルト動作)。
      -- nvim-treesitter (main) はまだ --no-bindings を渡すので、ここで除去。
      local ok_install, install = pcall(require, "nvim-treesitter.install")
      if ok_install then
        install.ts_generate_args = { "generate", "--abi", tostring(vim.treesitter.language_version) }
      end

      -- 非同期インストール (既にあれば no-op)
      local ts = require("nvim-treesitter")
      if type(ts.install) == "function" then
        ts.install(parsers)
      else
        -- fallback: main ブランチ未同期 or 旧 master の場合
        vim.schedule(function()
          vim.cmd("TSInstall! " .. table.concat(parsers, " "))
        end)
      end

      -- ハイライト/インデントを FileType フックで有効化
      -- (main ブランチは「自分で treesitter.start() を呼ぶ」設計に変わった)
      local function start_treesitter(bufnr)
        if vim.bo[bufnr].filetype == "" then
          return
        end

        if pcall(vim.treesitter.start, bufnr) then
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          start_treesitter(args.buf)
        end,
      })

      -- `nvim file.js` の初回バッファは FileType が先に発火することがある。
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          start_treesitter(bufnr)
        end
      end
    end,
  },

  --------------------------------------------------------------------
  -- conform.nvim: 保存時の自動フォーマット
  -- -------------------------------------------------------------------
  -- ファイル保存時に自動でフォーマッタを実行する。
  -- コミットや保存のタイミングでコードフォーマットを実行。
  -- -------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      format_on_save = {
        timeout_ms = 2000,       -- フォーマットのタイムアウト（ms）
        lsp_format = "fallback", -- conform で対応外の場合は LSP フォーマットにフォールバック
      },
      formatters_by_ft = {}, -- 各 lang/*.lua の setup() で動的に追加される
      formatters = {
        prettier = {
          -- プロジェクトに設定ファイル（.prettierrc等）がない場合のデフォルトを4スペースにする
          prepend_args = { "--tab-width", "4" },
        },
      },
    },
  },

  --------------------------------------------------------------------
  -- LuaSnip: 高機能スニペットエンジン
  -- -------------------------------------------------------------------
  -- Neovim 組み込みの vim.snippet は補完確定時にセッションが切れやすいため、
  -- より堅牢な LuaSnip をスニペットエンジンとして使用します。
  -- -------------------------------------------------------------------
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      -- VS Code 形式のスニペットを LuaSnip に読み込む
      require("luasnip.loaders.from_vscode").lazy_load()

      -- インサートモードを抜けた（Escキーなどを押した）時にスニペットのセッションを切断する
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          if
            ls.session.current_nodes[vim.api.nvim_get_current_buf()]
            and not ls.session.jump_active
          then
            ls.unlink_current()
          end
        end,
      })
    end,
  },
}
