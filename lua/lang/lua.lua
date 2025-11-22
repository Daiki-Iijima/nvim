local M = {}

function M.setup()
  -- Lua 用 LSP 設定（lua-language-server）
  ---@type vim.lsp.Config
  vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" }, -- lua-language-server が PATH に必要
    filetypes = { "lua" },
    root_markers = {
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      ".git",
    },
    settings = {
      Lua = {
        runtime = {
          -- Neovim は LuaJIT
          version = "LuaJIT",
        },
        diagnostics = {
          -- `vim` を未定義扱いにしない
          globals = { "vim" },
        },
        workspace = {
          -- Neovim の runtime の型情報も見る
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })

  -- フォーマッタ: stylua を Conform に登録
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.lua = { "stylua" }
  end
end

return M
