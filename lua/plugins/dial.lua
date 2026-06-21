-- =============================================================================
-- dial.nvim: スマートなインクリメント/デクリメント
-- =============================================================================
-- Ctrl+a (加算) / Ctrl+x (減算) を拡張し、数値だけでなく日付、時間、
-- 真偽値 (true ⇄ false), and ⇄ or, yes ⇄ no などの切り替えを可能にします。
-- =============================================================================

return {
  "monaqa/dial.nvim",
  keys = {
    {
      "<C-a>",
      function()
        return require("dial.map").inc_normal()
      end,
      expr = true,
      desc = "Dial: スマート加算",
    },
    {
      "<C-x>",
      function()
        return require("dial.map").dec_normal()
      end,
      expr = true,
      desc = "Dial: スマート減算",
    },
    {
      "<C-a>",
      function()
        return require("dial.map").inc_visual()
      end,
      expr = true,
      mode = "v",
      desc = "Dial: スマート加算 (選択)",
    },
    {
      "<C-x>",
      function()
        return require("dial.map").dec_visual()
      end,
      expr = true,
      mode = "v",
      desc = "Dial: スマート減算 (選択)",
    },
  },
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
  end,
}
