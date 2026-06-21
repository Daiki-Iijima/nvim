-- =============================================================================
-- which-key.nvim: キーマップヘルパー
-- =============================================================================
-- キーマップの入力を途中で止めると、次に押せるキー候補をポップアップ表示します。
-- コメントや LSP で付与した desc (説明文) を自動で抽出して表示してくれます。
-- =============================================================================

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- UIプリセット（helix がモダンで省スペースでおすすめ）
    preset = "helix",
    -- ポップアップが表示されるまでの遅延時間 (ms)
    delay = function(ctx)
      return ctx.plugin and 0 or 500
    end,
    spec = {
      { "<leader>f", group = "Find / Format", icon = "🔍" },
      { "<leader>g", group = "Git", icon = "󰊢 " },
      { "<leader>l", group = "LSP", icon = " " },
      { "<leader>d", group = "Diagnostics / Quickfix", icon = " " },
      { "<leader>c", group = "Code / Linter", icon = "💻" },
      { "<leader>t", group = "Trouble", icon = "🚦" },
      { "<leader>s", group = "Search / Replace", icon = "🔁" },
    },
  },
}
