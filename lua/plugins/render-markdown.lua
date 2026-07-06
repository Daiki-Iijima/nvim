-- =============================================================================
-- render-markdown.nvim: Markdown のリッチレンダリング
-- =============================================================================
-- Markdown ファイルをそのまま Neovim 上で視覚的に整形表示する。
-- 実際のファイル内容は変えず、画面描画だけを装飾する。
--
-- 主な視覚効果:
--   見出し  → レベルごとに異なるアイコンと色で表示（H1〜H6）
--   コードブロック → 背景色付きで表示、言語名も色分け
--   リスト  → 階層に応じてアイコンを変える（●○◆◇）
--   テーブル → 罫線を整列表示
--   チェックボックス → [ ] / [x] をアイコンで表示
--
-- 依存:
--   nvim-treesitter → Markdown の構文解析に使用
--   nvim-web-devicons → 言語アイコンの表示に使用
-- =============================================================================

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "codecompanion" }, -- Markdown/CodeCompanion を開いたときだけ読み込む
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    heading = {
      -- 見出しレベル（H1〜H6）ごとのアイコン
      icons = { "┃ ", "┃ ", "┃ ", "┃ ", "┃ ", "┃ " },
    },
    code = {
      enabled = true,    -- コードブロックの装飾を有効化
      style   = "full",  -- "full" → 行全体に背景色を付ける（"normal" は左端のみ）
    },
    bullet = {
      -- リストの階層ごとにアイコンを変える
      icons = { "●", "○", "◆", "◇" },
    },
  },
}
