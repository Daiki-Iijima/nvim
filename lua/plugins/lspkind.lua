-- =============================================================================
-- lspkind.nvim: 補完候補に種別アイコンを表示
-- =============================================================================
-- nvim-cmp の補完ウィンドウに VS Code 風の絵文字アイコンを追加する。
-- 「この補完候補が関数なのか変数なのかスニペットなのか」を視覚的に区別できる。
--
-- 表示モード:
--   "symbol"      → アイコンのみ（コンパクト）
--   "symbol_text" → アイコン + 種別名テキスト
--   "text"        → テキストのみ（アイコンなし）
--
-- ここでは init() でアイコンを登録し、
-- 実際の補完フォーマットは lsp.lua の nvim-cmp 側で lspkind.cmp_format() を使う。
-- =============================================================================

return {
  "onsails/lspkind.nvim",
  event = "InsertEnter", -- 補完が起動するタイミングで読み込む

  config = function()
    local lspkind = require("lspkind")

    lspkind.init({
      mode = "symbol_text", -- アイコン + 種別名で初期化（表示は cmp_format() で上書き可能）
      preset = "default",   -- デフォルトのアイコンセットを使用

      -- 各補完種別のカスタムアイコン（Nerd Font が必要）
      symbol_map = {
        Text          = "󰉿",  -- 単純なテキスト
        Method        = "󰆧",  -- メソッド（クラスに属する関数）
        Function      = "󰊕",  -- 関数
        Constructor   = "󰒓",  -- コンストラクタ
        Field         = "󰜢",  -- フィールド（構造体のメンバ変数）
        Variable      = "󰀫",  -- 変数
        Class         = "󰠱",  -- クラス
        Interface     = "",  -- インターフェース
        Module        = "󰕳",  -- モジュール / パッケージ
        Property      = "󰜢",  -- プロパティ
        Unit          = "",  -- 単位（定数など）
        Value         = "󰎠",  -- 値
        Enum          = "",  -- 列挙型
        Keyword       = "󰌋",  -- キーワード（if / for など）
        Snippet       = "",  -- スニペット
        Color         = "󰏘",  -- カラー値
        File          = "󰈙",  -- ファイル
        Reference     = "󰈇",  -- 参照
        Folder        = "󰉋",  -- フォルダ
        EnumMember    = "",  -- 列挙型のメンバ
        Constant      = "󰏿",  -- 定数
        Struct        = "󰙅",  -- 構造体
        Event         = "",  -- イベント
        Operator      = "󰆕",  -- 演算子
        TypeParameter = "",  -- 型パラメータ（ジェネリクス）
      },
    })
  end,
}
