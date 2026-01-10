local M = {}

function M.setup()
  ---@type vim.lsp.Config
  vim.lsp.config("clangd", {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--pch-storage=memory",
    },

    -- ✅ ヘッダも filetype に入れる
    -- Neovim の filetype は環境や設定で "h" / "hpp" だったり "c" 扱いだったりするので
    -- ここは広めにカバーしておくのが安全
    filetypes = {
      "c",
      "cpp",
      "objc",
      "objcpp",
      "cuda",
      "h",
      "hpp",
    },

    root_markers = {
      "compile_commands.json",
      "compile_flags.txt",
      ".clangd",
      ".git",
    },

    -- ここは任意：プロジェクトに compile_commands が無い時の保険を少し効かせたいなら
    -- init_options = { fallbackFlags = { "-std=c++20" } },
  })
end

return M
