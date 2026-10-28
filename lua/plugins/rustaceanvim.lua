-- rustaceanvim: rust-analyzer の高機能ラッパー
-- rust_analyzer の直接起動は行わず、このプラグインに一任する
--
-- 提供される追加機能:
--   :RustLsp expandMacro     -- マクロ展開の表示
--   :RustLsp openCargo       -- Cargo.toml を開く
--   :RustLsp parentModule    -- 親モジュールへ移動
--   :RustLsp runnables       -- 実行可能なターゲット一覧
--   :RustLsp debuggables     -- デバッグ可能なターゲット一覧
--   :RustLsp explainError    -- エラーコードの解説
--   :RustLsp renderDiagnostic -- 診断のレンダリング

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        -- LSP の共通キーは lang/_loader.lua の LspAttach が張る
        server = {
          default_settings = require("lang.rust").settings,
        },
        -- DAP: アダプタは書かない。codelldb / lldb-dap が PATH にあれば rustaceanvim が見つけて使う
      }

      -- Rust ファイル向け追加キーマップ（<leader>l = 言語ごと）
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "<leader>lm", function() vim.cmd.RustLsp("expandMacro") end,
            vim.tbl_extend("force", opts, { desc = "Rust: マクロ展開" }))
          vim.keymap.set("n", "<leader>lo", function() vim.cmd.RustLsp("openCargo") end,
            vim.tbl_extend("force", opts, { desc = "Rust: Cargo.toml を開く" }))
          vim.keymap.set("n", "<leader>lp", function() vim.cmd.RustLsp("parentModule") end,
            vim.tbl_extend("force", opts, { desc = "Rust: 親モジュールへ" }))
          vim.keymap.set("n", "<leader>lr", function() vim.cmd.RustLsp("runnables") end,
            vim.tbl_extend("force", opts, { desc = "Rust: 実行ターゲット一覧" }))
          vim.keymap.set("n", "<leader>ld", function() vim.cmd.RustLsp("debuggables") end,
            vim.tbl_extend("force", opts, { desc = "Rust: デバッグターゲット一覧" }))
          vim.keymap.set("n", "<leader>le", function() vim.cmd.RustLsp("explainError") end,
            vim.tbl_extend("force", opts, { desc = "Rust: エラーコードを解説" }))
        end,
      })
    end,
  },
}
