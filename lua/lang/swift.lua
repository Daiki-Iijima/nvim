local M = {}

function M.setup()
  -- Swift / SourceKit 用の個別設定
  vim.lsp.config("sourcekit", {
    cmd = { "xcrun", "sourcekit-lsp" },
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
