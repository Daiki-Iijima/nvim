-- =============================================================================
-- エディタ基本設定
-- =============================================================================

-- 行番号
vim.opt.number         = true  -- 絶対行番号を表示
vim.opt.relativenumber = true  -- 現在行以外は相対行番号で表示（移動量の計算がしやすい）

-- クリップボード
vim.opt.clipboard = "unnamedplus" -- OS のクリップボードと共有（yank / paste が OS と連携）

-- インデント
vim.opt.expandtab   = true -- Tab キーでスペースを挿入（タブ文字を使わない）
vim.opt.shiftwidth  = 2    -- >> や自動インデントで使うスペース数
vim.opt.tabstop     = 2    -- タブ文字を表示するときの幅
vim.opt.softtabstop = 2    -- Tab / Backspace キーで動く幅

-- サインカラム（行番号の左にある余白）
vim.opt.signcolumn = "yes:2" -- 常に 2 列分確保（git サイン + 診断アイコンが重ならない）

-- 折りたたみ
vim.opt.foldmethod = "indent" -- インデントの深さをもとに折りたたみ範囲を決める
vim.opt.foldlevel  = 99       -- デフォルトですべて展開した状態にする（99 = 実質全開）
vim.opt.foldenable = true     -- 折りたたみ機能を有効化

-- ベル音
vim.opt.belloff    = "all"  -- すべてのイベントでベル音を鳴らさない
vim.opt.visualbell = true   -- ビープ音の代わりに画面フラッシュを使う（これも実質無音）
vim.opt.errorbells = false  -- エラー時のベル音を無効化

-- 文字コード（Windows 環境でも文字化けしないように）
vim.opt.encoding     = "utf-8"
vim.opt.fileencoding = "utf-8"

-- =============================================================================
-- 診断（Diagnostics）の表示設定
-- =============================================================================
-- カーソル位置の診断をフロートウィンドウで表示するときの見た目を設定する。
-- 実際に表示するキーマップは lua/lang/_loader.lua の on_attach() に定義されている。
vim.diagnostic.config({
  float = {
    border = "rounded", -- 角丸の枠線
    scope  = "cursor",  -- カーソルがある行の診断だけ表示
    source = true,      -- 診断の発生源（どの LSP か）を表示
  },
})

-- =============================================================================
-- LSP フロートウィンドウの枠線を統一
-- =============================================================================
-- vim.lsp.util.open_floating_preview() にモンキーパッチを当てて、
-- hover / signature_help などすべての LSP フロートに rounded 枠線を強制適用する。
local orig_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  opts        = opts or {}
  opts.border = opts.border or "rounded"
  return orig_open_floating_preview(contents, syntax, opts, ...)
end

-- =============================================================================
-- プロバイダーの無効化（起動速度の向上と checkhealth の警告抑制）
-- =============================================================================
-- Node.js, Python, Ruby, Perl 等の外部言語プロバイダーは
-- 最近の Lua 製プラグインではほぼ不要なため、無効化して高速化します。
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

