-- =============================================================================
-- dial.nvim: スマートなインクリメント/デクリメント
-- =============================================================================
-- 数値だけでなく日付、時間、真偽値 (true ⇄ false), and ⇄ or, yes ⇄ no などをカーソル下で切り替える。
-- キーは張らない（<C-a>/<C-x> は Neovim 標準の数値の加減算のまま）。コマンドパレット（<leader>:）から
--   :DialIncrement / :DialDecrement
-- =============================================================================

return {
  "monaqa/dial.nvim",
  cmd = { "DialIncrement", "DialDecrement" },
  config = function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%Y/%m/%d"],
        augend.date.alias["%H:%M:%S"],
        augend.constant.alias.bool, -- true/false の切り替え
        augend.constant.new({
          elements = { "and", "or" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "yes", "no" },
          word = true,
          cyclic = true,
        }),
      },
    })
    for name, plug in pairs({ DialIncrement = "<Plug>(dial-increment)", DialDecrement = "<Plug>(dial-decrement)" }) do
      vim.api.nvim_create_user_command(name, function()
        vim.api.nvim_feedkeys(vim.keycode(plug), "m", false)
      end, { desc = "Dial: カーソル下を切り替え" })
    end
  end,
}
