local M = {}

-- Rust側でも capabilities を明示（継承事故を防ぐ）
local function make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end
  return capabilities
end

function M.setup()
  vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },

    -- 追加
    capabilities = make_capabilities(),

    -- （共通on_attachを使ってるならここも追加推奨）
    -- on_attach = require("lsp").on_attach, みたいに参照できる形なら入れる

    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = true,
        check = { command = "clippy" },
        procMacro = { enable = true },
        inlayHints = {
          bindingModeHints = { enable = true },
          closureReturnTypeHints = { enable = "with_block" },
          lifetimeElisionHints = { enable = "skip_trivial" },
          parameterHints = { enable = true },
          reborrowHints = { enable = "mutable" },
          typeHints = { enable = true },
        },
      },
    },
  })

  local ok_conform, conform = pcall(require, "conform")
  if ok_conform then
    conform.formatters_by_ft = conform.formatters_by_ft or {}
    conform.formatters_by_ft.rust = { "rustfmt" }
  end
end

return M
