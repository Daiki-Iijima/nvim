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
    version = "^5",
    ft = { "rust" },
    init = function()
      local loader = require("lang._loader")
      local rust_settings = require("lang.rust").settings

      vim.g.rustaceanvim = {
        server = {
          on_attach = loader.on_attach,
          default_settings = rust_settings,
        },
        -- DAP 統合（nvim-dap が入っている場合は codelldb を自動検出）
        dap = {
          adapter = {
            type    = "server",
            port    = "${port}",
            host    = "127.0.0.1",
            executable = {
              command = "codelldb",
              args    = { "--port", "${port}" },
            },
          },
        },
      }

      -- Rust ファイル向け追加キーマップ
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "<leader>rm", function() vim.cmd.RustLsp("expandMacro") end,
            vim.tbl_extend("force", opts, { desc = "Rust: マクロ展開" }))
          vim.keymap.set("n", "<leader>ro", function() vim.cmd.RustLsp("openCargo") end,
            vim.tbl_extend("force", opts, { desc = "Rust: Cargo.toml を開く" }))
          vim.keymap.set("n", "<leader>rp", function() vim.cmd.RustLsp("parentModule") end,
            vim.tbl_extend("force", opts, { desc = "Rust: 親モジュールへ" }))
          vim.keymap.set("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end,
            vim.tbl_extend("force", opts, { desc = "Rust: 実行ターゲット一覧" }))
          vim.keymap.set("n", "<leader>rd", function() vim.cmd.RustLsp("debuggables") end,
            vim.tbl_extend("force", opts, { desc = "Rust: デバッグターゲット一覧" }))
          vim.keymap.set("n", "<leader>re", function() vim.cmd.RustLsp("explainError") end,
            vim.tbl_extend("force", opts, { desc = "Rust: エラーコードを解説" }))
        end,
      })
    end,
  },
}
