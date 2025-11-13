return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        notify = false,
        use_treesitter = true, -- 構文に沿って範囲検出
        style = {
          { fg = "#8ec07c" },  -- Gruvboxに合わせた色
        },
      },
      indent = {
        enable = false,  -- 非表示
        chars = { "│" }, -- インデントラインの形
        style = {
          { fg = "#504945" },
        },
      },
      line_num = {
        enable = false, -- ブロック範囲に行番号を表示する機能（重いならfalse）
      },
      blank = {
        enable = false, -- 空行のインデントライン描画
      },
    })
  end,
}
