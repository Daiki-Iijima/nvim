-- bufferline.nvim: バッファをタブのように表示する
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<Tab>",   "<cmd>BufferLineCycleNext<cr>", desc = "次のバッファへ" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "前のバッファへ" },
    { "<leader>bd", "<cmd>bdelete<cr>",          desc = "バッファを閉じる" },
  },
  opts = {
    options = {
      mode = "buffers",
      numbers = "none",
      close_command = "bdelete! %d",
      diagnostics = "nvim_lsp",         -- LSP の診断アイコンをタブに表示
      diagnostics_indicator = function(_, _, diag)
        local icons = { error = " ", warning = " " }
        return (diag.error and icons.error .. diag.error or "")
          .. (diag.warning and icons.warning .. diag.warning or "")
      end,
      offsets = {
        {
          filetype   = "snacks_layout_box", -- Snacks Explorer が開いている分だけ右にずらす
          text       = "",
          highlight  = "Directory",
          separator  = true,
        },
      },
      show_buffer_close_icons = true,
      show_close_icon         = false,
      separator_style         = "slant", -- "slant" | "slope" | "thick" | "thin"
      always_show_bufferline  = true,
      icon_padding            = 1,       -- アイコンの左右に余白を追加して見切れを防ぐ
      tab_size                = 18,      -- タブの最小幅
    },
  },
}
