-- =============================================================================
-- copilot.lua: GitHub Copilot の Lua クライアント
-- =============================================================================
-- インサートモードでコードの続きをグレーのゴーストテキスト（薄いテキスト）で提案します。
-- Alt + l または Tab（補完窓が開いていないとき）で提案を受け入れます。
-- =============================================================================

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter", -- 挿入モードに入った段階で起動
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>", -- Alt + l で提案を確定（バックアップ用）
          next = "<M-]>",   -- Alt + ] で次の候補を表示
          prev = "<M-[>",   -- Alt + [ で前の候補を表示
          dismiss = "<C-]>", -- Ctrl + ] で提案を非表示にする
        },
      },
      panel = { enabled = false }, -- パネル表示は無効化（suggestion のみで十分強力なため）
    })
  end,
}
