-- =============================================================================
-- LSP・補完・シンタックス・フォーマット の統合設定
-- =============================================================================
-- このファイルで管理するプラグイン:
--   nvim-lspconfig  → LSP クライアントの起動管理
--   nvim-cmp        → 補完エンジン（補完ウィンドウの表示・選択）
--   LuaSnip         → スニペットエンジン
--   nvim-treesitter → シンタックスハイライト・インデント
--   conform.nvim    → ファイル保存時の自動フォーマット
-- =============================================================================

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
  -- nvim-cmp: 補完エンジン
  -- -------------------------------------------------------------------
  -- 入力中に候補をポップアップ表示する補完フレームワーク。
  -- 複数の「補完ソース」からデータを集約して表示する。
  --
  -- 補完ソース（sources）の優先順:
  --   1. lazydev   → Neovim API（Lua 編集時のみ最優先）
  --   2. nvim_lsp  → LSP サーバーからの補完（最も重要）
  --   3. luasnip   → スニペット展開
  --   4. buffer    → 現在開いているバッファ内の単語（3 文字以上で起動）
  --   5. path      → ファイルシステムのパス補完
  --
  -- キーマップ:
  --   Enter      → 候補を確定
  --   Ctrl+Space → 補完を手動で起動
  --   Tab        → 次の候補 / スニペットの次のプレースホルダへ
  --   Shift+Tab  → 前の候補 / スニペットの前のプレースホルダへ
  -- -------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- 挿入モードに入ったときだけ読み込む
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- LSP からの補完候補を nvim-cmp に渡す接続層
      "hrsh7th/cmp-buffer",    -- 開いているバッファ内の単語を補完候補にする
      "hrsh7th/cmp-path",      -- ファイルパスを補完候補にする
      {
        "L3MON4D3/LuaSnip",    -- スニペットエンジン本体
        dependencies = {
          -- friendly-snippets: VS Code 互換のスニペット集
          -- HTML / CSS / JS / TS / Rust / Python など主要言語のスニペットが入る
          "rafamadriz/friendly-snippets",
        },
        config = function()
          -- VS Code 形式のスニペットを LuaSnip に読み込む
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "saadparwaiz1/cmp_luasnip", -- LuaSnip のスニペットを nvim-cmp に渡す接続層
      "onsails/lspkind.nvim",     -- 補完候補に種別アイコンを付ける（lspkind.lua 参照）
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      vim.o.pumheight = 10 -- 補完ポップアップの最大表示行数

      cmp.setup({
        -- スニペットの展開を LuaSnip に委ねる
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump() -- スニペット内の次のプレースホルダへ
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1) -- スニペット内の前のプレースホルダへ
            else
              fallback()
            end
          end,
        }),

        -- sources をグループ化すると、グループ 1 に候補がある場合グループ 2 は非表示になる
        -- → LSP・スニペット候補がある間は buffer・path が邪魔にならない
        sources = cmp.config.sources(
          {
            { name = "lazydev", group_index = 0 }, -- Lua 編集時に最優先（index = 0 が最高）
            { name = "nvim_lsp" },
            { name = "luasnip" },
          },
          {
            { name = "buffer", keyword_length = 3 }, -- 3 文字以上入力したら起動
            { name = "path" },
          }
        ),

        sorting = {
          comparators = {
            -- スニペットを候補リストの最下部に押し下げる比較関数
            function(entry1, entry2)
              local types = require("cmp.types")
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              if kind1 == types.lsp.CompletionItemKind.Snippet and kind2 ~= types.lsp.CompletionItemKind.Snippet then
                return false
              end
              if kind2 == types.lsp.CompletionItemKind.Snippet and kind1 ~= types.lsp.CompletionItemKind.Snippet then
                return true
              end
            end,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },

        window = {
          completion = {
            winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:None",
            max_height = 10,
          },
          documentation = cmp.config.window.bordered({
            max_width  = 60,
            max_height = 15,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,Search:None",
          }),
        },

        formatting = {
          fields = { "abbr", "kind" }, -- 表示カラム: 補完名 → 種別アイコン
          format = lspkind.cmp_format({
            mode         = "symbol", -- アイコンのみ表示（"symbol_text" にすると文字も出る）
            maxwidth     = 40,
            ellipsis_char = "…",
          }),
        },
      })
    end,
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
  -- 言語ごとのフォーマッタ設定は lua/lang/ 以下の各ファイルで登録する:
  --   lang/lua.lua        → stylua
  --   lang/swift.lua      → swiftformat
  --   lang/python.lua     → black
  --   lang/go.lua         → goimports
  --   lang/php.lua        → pint
  --   lang/typescript.lua → prettier（JS / TS）
  --   lang/web.lua        → prettier（HTML / CSS / SCSS / JSON / YAML）
  --
  -- lsp_format = "fallback":
  --   conform が対応フォーマッタを見つけられなかった場合に LSP のフォーマットを使う
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
    },
  },
}
