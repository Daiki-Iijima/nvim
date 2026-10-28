-- code_runner.nvim: キーは張らない。コマンドパレット（<leader>:）か直接打つ:
--   :RunCode        今のファイルを実行（フロートに出力）
--   :RunCode 引数   引数を付けて実行
return {
  "CRAG666/code_runner.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "RunCode", "RunFile", "RunProject", "RunClose" },
  opts = {
    mode = "float",      -- フローティングウィンドウに出力
    focus = true,        -- 実行後フロートにフォーカス
    startinsert = false, -- インサートモードには入らない
    float = {
      border = "rounded",
    },
    filetype = {
      swift      = "swift",
      lua        = "lua",
      python     = "python3 -u",
      go         = "go run",
      cs         = "dotnet run",
      rust       = "cargo run",
      php        = "php",
      javascript = "node",
      typescript = "npx tsx",
    },
  },
}
