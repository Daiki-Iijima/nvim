-- =============================================================================
-- Rust の LSP 設定（rustaceanvim 向け設定値エクスポート）
-- =============================================================================
-- ⚠ このファイルは rust-analyzer を直接起動しない。
--   rust-analyzer の起動・管理は lua/plugins/rustaceanvim.lua が担当する。
--   このファイルは rustaceanvim.lua から require して設定値を渡すために使う。
-- =============================================================================

local M = {}

-- rust-analyzer に渡す設定値
M.settings = {
  ["rust-analyzer"] = {
    cargo = {
      allFeatures = true, -- Cargo.toml の全機能フラグを有効にしてチェック
    },
    checkOnSave = true,
    check = {
      command = "clippy", -- 保存時に cargo check の代わりに clippy を使う（より厳格）
    },
    procMacro = {
      enable = true, -- プロシージャルマクロを展開して補完・解析に使う
    },
    inlayHints = {
      -- インレイヒント: コード上にオーバーレイで型情報などを表示する機能
      bindingModeHints       = { enable = true },                  -- 束縛モード（ref / mut）を表示
      closureReturnTypeHints = { enable = "with_block" },          -- ブロックを持つクロージャの戻り値型を表示
      lifetimeElisionHints   = { enable = "skip_trivial" },        -- 省略できないライフタイムを表示
      parameterHints         = { enable = true },                  -- 関数引数名を表示
      reborrowHints          = { enable = "mutable" },             -- mutable の再借用を表示
      typeHints              = { enable = true },                  -- 変数の型を表示
    },
  },
}

-- rustaceanvim が rust_analyzer を管理するため setup() は何もしない
function M.setup() end

return M
