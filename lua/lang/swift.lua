local M = {}

function M.setup()
  -- macOS は xcrun 経由、Linux 等はインストール済みの sourcekit-lsp を直接呼ぶ
  local sourcekit_cmd = (vim.fn.has("mac") == 1)
    and { "xcrun", "sourcekit-lsp" }
    or  { "sourcekit-lsp" }

  -- ルートは nvim-lspconfig の root_dir 関数で決める
  -- （buildServer.json → *.xcodeproj / *.xcworkspace → Package.swift → .git。root_markers はグロブを扱えない）
  vim.lsp.config("sourcekit", {
    cmd = sourcekit_cmd,
    filetypes = { "swift" }, -- C / C++ は clangd に任せる
  })

  -- フォーマッタ: swiftformat を Conform に登録（入っていなければ LSP にフォールバック）
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.swift = { "swiftformat" } -- or "swift-format"
  end
end

return M
