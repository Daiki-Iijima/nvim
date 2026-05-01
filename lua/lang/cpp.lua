local M = {}

function M.setup()
  -- C / C++ / Objective-C 用の clangd 設定
  vim.lsp.config("clangd", {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
    },
    root_markers = {
      "compile_commands.json",
      "compile_flags.txt",
      "CMakeLists.txt",
      "Makefile",
      ".clangd",
      ".git",
    },
  })
end

return M
