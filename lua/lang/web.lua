-- =============================================================================
-- Web 系言語の LSP 設定
-- =============================================================================
-- 対象言語: HTML / CSS / SCSS / Less / Tailwind CSS / Emmet / JSON / YAML
--
-- 必要なインストール（初回のみ）:
--   npm install -g vscode-langservers-extracted  → html / cssls / jsonls
--   npm install -g @tailwindcss/language-server  → tailwindcss
--   npm install -g emmet-language-server          → emmet
--   npm install -g yaml-language-server           → yamlls
-- =============================================================================

local M = {}

function M.setup()
  --------------------------------------------------------------------
  -- HTML LSP（vscode-html-language-server）
  -- -------------------------------------------------------------------
  -- HTML タグの補完・属性の提案・エラー検出を提供する。
  -- フォーマットは prettier に委ねるため provideFormatter = false にしている。
  -- -------------------------------------------------------------------
  vim.lsp.config("html", {
    cmd        = { "vscode-html-language-server", "--stdio" },
    filetypes  = { "html", "htmldjango" },
    root_markers = { "package.json", ".git" },
    init_options = {
      provideFormatter = false, -- フォーマットは prettier（conform.nvim）に委ねる
    },
  })

  --------------------------------------------------------------------
  -- CSS LSP（vscode-css-language-server）
  -- -------------------------------------------------------------------
  -- CSS / SCSS / Less のプロパティ補完・バリデーション・定義ジャンプを提供する。
  -- -------------------------------------------------------------------
  vim.lsp.config("cssls", {
    cmd        = { "vscode-css-language-server", "--stdio" },
    filetypes  = { "css", "scss", "less" },
    root_markers = { "package.json", ".git" },
    settings = {
      css  = { validate = true },
      scss = { validate = true },
      less = { validate = true },
    },
    init_options = {
      provideFormatter = false,
    },
  })

  --------------------------------------------------------------------
  -- Tailwind CSS LSP（tailwindcss-language-server）
  -- -------------------------------------------------------------------
  -- クラス名のインライン補完・カラープレビューを提供する。
  -- root_markers に tailwind.config.* がある場合のみ起動する（他プロジェクトに干渉しない）。
  --
  -- experimental.classRegex: cva / cx などのユーティリティ関数の引数内でも
  -- Tailwind クラスの補完が効くようにするための正規表現。
  -- -------------------------------------------------------------------
  vim.lsp.config("tailwindcss", {
    cmd        = { "tailwindcss-language-server", "--stdio" },
    filetypes  = {
      "html", "css", "scss", "less",
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
    },
    root_markers = {
      "tailwind.config.js", "tailwind.config.ts",
      "tailwind.config.mjs", "tailwind.config.cjs",
      "package.json", ".git",
    },
    settings = {
      tailwindCSS = {
        validate = true,
        experimental = {
          classRegex = {
            -- cva() / cx() など CSS-in-JS ライブラリ内でもクラス補完を効かせる
            { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
            { "cx\\(([^)]*)\\)",  "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          },
        },
      },
    },
  })

  --------------------------------------------------------------------
  -- Emmet LSP（emmet-language-server）
  -- -------------------------------------------------------------------
  -- Emmet 略語の補完・展開を提供する。
  -- 例: div.container>ul>li*3<Tab> → <div class="container"><ul><li></li>...
  -- -------------------------------------------------------------------
  vim.lsp.config("emmet_language_server", {
    cmd        = { "emmet-language-server", "--stdio" },
    filetypes  = {
      "html", "css", "scss", "less",
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
    },
    root_markers = { "package.json", ".git" },
    init_options = {
      showSuggestionsAsSnippets = true, -- 略語展開をスニペットとして補完候補に出す
    },
  })

  --------------------------------------------------------------------
  -- JSON LSP（vscode-json-language-server）
  -- -------------------------------------------------------------------
  -- JSON のスキーマバリデーション・補完を提供する。
  -- package.json / tsconfig.json などで自動的にスキーマが適用される。
  -- -------------------------------------------------------------------
  vim.lsp.config("jsonls", {
    cmd        = { "vscode-json-language-server", "--stdio" },
    filetypes  = { "json", "jsonc" },
    root_markers = { ".git" },
    settings = {
      json = {
        validate = { enable = true },
      },
    },
    init_options = {
      provideFormatter = false,
    },
  })

  --------------------------------------------------------------------
  -- YAML LSP（yaml-language-server）
  -- -------------------------------------------------------------------
  -- YAML のスキーマバリデーション・補完を提供する。
  -- GitHub Actions / Docker Compose などの設定ファイルで自動スキーマ適用。
  -- -------------------------------------------------------------------
  vim.lsp.config("yamlls", {
    cmd        = { "yaml-language-server", "--stdio" },
    filetypes  = { "yaml", "yaml.docker-compose" },
    root_markers = { ".git" },
    settings = {
      yaml = {
        validate   = true,
        hover      = true,
        completion = true,
        format     = { enable = false }, -- フォーマットは prettier に委ねる
        schemas = {
          -- GitHub Actions のワークフローファイルにスキーマを自動適用
          ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
          -- Docker Compose ファイルにスキーマを自動適用
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
        },
      },
    },
  })

  --------------------------------------------------------------------
  -- フォーマッタ登録（prettier → conform.nvim）
  -- -------------------------------------------------------------------
  -- Web 系ファイルタイプのフォーマットをすべて prettier に統一する。
  -- prettier は JS / TS / HTML / CSS / JSON / YAML を 1 つのツールで扱える。
  -- -------------------------------------------------------------------
  local ok, conform = pcall(require, "conform")
  if ok then
    local ft = conform.formatters_by_ft or {}
    ft.html  = { "prettier" }
    ft.css   = { "prettier" }
    ft.scss  = { "prettier" }
    ft.less  = { "prettier" }
    ft.json  = { "prettier" }
    ft.jsonc = { "prettier" }
    ft.yaml  = { "prettier" }
    conform.formatters_by_ft = ft
  end
end

return M
