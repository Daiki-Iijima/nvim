-- =============================================================================
-- gruvbox.nvim: カラースキーム
-- =============================================================================
-- Neovim 向けに書き直された Gruvbox テーマ。
-- レトロな雰囲気のウォームカラーで目に優しい配色。
--
-- contrast: "hard" / "medium"（デフォルト）/ "soft" から選択
--   soft   → 背景を少し明るく・コントラストを抑えめにする
-- transparent_mode: true にするとターミナルの背景が透けて見える
-- =============================================================================

return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,        -- 起動時に必ず読み込む（カラースキームは早期ロード必須）
    priority = 1000,     -- 他のプラグインより先にロードして配色を確定させる
    config = function()
      require("gruvbox").setup({
        contrast = "medium",         -- 背景のコントラストを標準にする
        transparent_mode = false,   -- ターミナルの背景透過を無効にする
      })
      vim.cmd("colorscheme gruvbox")

      -- Markdown の見出しのカスタマイズ（縦棒の明るい色 ＆ 各階層のうっすら背景色）
      local heading_colors = {
        { fg = "#fabd2f", bg = "#332d1e" }, -- H1: 黄
        { fg = "#b8bb26", bg = "#252d1d" }, -- H2: 緑
        { fg = "#83a598", bg = "#1e292d" }, -- H3: 青
        { fg = "#d3869b", bg = "#2d1e29" }, -- H4: 紫
        { fg = "#8ec07c", bg = "#1e2d25" }, -- H5: アクア
        { fg = "#fe8019", bg = "#33241e" }, -- H6: オレンジ
      }
      for i, color in ipairs(heading_colors) do
        -- 縦棒とテキストの基本色
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i, { fg = color.fg, bold = true })
        -- うっすらとした背景色（行全体）
        vim.api.nvim_set_hl(0, "RenderMarkdownH" .. i .. "Bg", { fg = color.fg, bg = color.bg, bold = true })
        -- Treesitter 標準の見出し背景も一旦クリア（干渉防止）
        vim.api.nvim_set_hl(0, "@markup.heading." .. i .. ".markdown", { fg = color.fg, bg = "NONE", bold = true })
      end

      -- snacks.nvim のインデントガイドのハイライトを上書き設定
      vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#504945", nocombine = true })      -- 通常のインデント線（暗めの灰色）
      vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#fe8019", nocombine = true }) -- アクティブスコープのインデント線（オレンジ）
    end,
  },
}
