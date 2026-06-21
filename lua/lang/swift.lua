local M = {}

function M.setup()
  -- macOS は xcrun 経由、Linux 等はインストール済みの sourcekit-lsp を直接呼ぶ
  local sourcekit_cmd = (vim.fn.has("mac") == 1)
    and { "xcrun", "sourcekit-lsp" }
    or  { "sourcekit-lsp" }

  vim.lsp.config("sourcekit", {
    cmd = sourcekit_cmd,
    filetypes = { "swift" },
    root_markers = {
      "Package.swift",
      ".git",
      "*.xcodeproj",
      "*.xcworkspace",
      "buildServer.json",
    },
  })

  -- フォーマッタ: swiftformat を Conform に登録
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.swift = { "swiftformat" } -- or "swift-format"
  end
end

return M
