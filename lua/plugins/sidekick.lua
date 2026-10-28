-- =============================================================================
-- sidekick.nvim: AI の CLI（omp）を Neovim の端末で開き、選択範囲やファイルを送る
-- =============================================================================
-- Copilot の Next Edit Suggestions（NES）は使わない。
--
-- キーマップ:
--   <leader>aa -> omp を右の端末で開く / 隠す
--   <leader>at -> カーソル位置（ビジュアルなら選択範囲）を omp に送る
--   <leader>av -> 選択範囲の中身を omp に送る（ビジュアル）
--   <leader>af -> 今のファイルを omp に送る
--   <leader>ap -> 定型プロンプト（説明・修正・テスト…）を選んで送る
--   端末の中: <C-.> で隠す、<C-p> でプロンプト挿入
-- =============================================================================

local function cli(fn, opts)
  return function() require("sidekick.cli")[fn](vim.tbl_extend("force", { name = "omp" }, opts or {})) end
end

return {
  "folke/sidekick.nvim",
  cmd = "Sidekick",
  opts = {
    nes = { enabled = false },
    copilot = { status = { enabled = false } },
    cli = {
      tools = {
        omp = {
          cmd = { "omp" },
          is_proc = "\\<omp\\>",
          resume = { "--resume" },
          continue = { "--continue" },
        },
      },
    },
  },
  keys = {
    { "<leader>aa", cli("toggle", { focus = true }), desc = "omp: 開く / 隠す" },
    { "<leader>at", cli("send", { msg = "{this}" }), mode = { "n", "x" }, desc = "omp: カーソル位置 / 選択を送る" },
    { "<leader>av", cli("send", { msg = "{selection}" }), mode = "x", desc = "omp: 選択範囲を送る" },
    { "<leader>af", cli("send", { msg = "{file}" }), desc = "omp: ファイルを送る" },
    { "<leader>ap", cli("prompt"), mode = { "n", "x" }, desc = "omp: プロンプトを選んで送る" },
  },
}
