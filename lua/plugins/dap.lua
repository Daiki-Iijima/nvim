-- nvim-dap: デバッグアダプタプロトコル
--
-- codelldb のインストール（Rust / C / C++ デバッグに必要）:
--   VS Code の CodeLLDB 拡張からバイナリを取得するか、以下を使用:
--   brew install llvm  # macOS: lldb-dap が含まれる
--
-- キーマップ:
--   <F5>         -- 続行 / デバッグ開始
--   <F9>         -- ブレークポイント切替
--   <F10>        -- ステップオーバー
--   <F11>        -- ステップイン
--   <F12>        -- ステップアウト
--   <leader>dR   -- REPL を開く
--   <leader>dU   -- DAP の画面（nvim-dap-view）の表示切替
--   <leader>dl   -- 直前のデバッグを再実行

return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    keys = {
      { "<F5>",        desc = "DAP: 続行" },
      { "<F9>",        desc = "DAP: ブレークポイント切替" },
      { "<F10>",       desc = "DAP: ステップオーバー" },
      { "<F11>",       desc = "DAP: ステップイン" },
      { "<F12>",       desc = "DAP: ステップアウト" },
      { "<leader>dR",  desc = "DAP: REPL を開く" },
      { "<leader>dU",  desc = "DAP: UI 切替" },
      { "<leader>dl",  desc = "DAP: 直前を再実行" },
    },
    dependencies = {
      ------------------------------------------------------------
      -- DAP の画面（変数・ブレークポイント・スタック・REPL を下のタブで切り替え）
      ------------------------------------------------------------
      {
        "igorlfs/nvim-dap-view",
        opts = {
          auto_toggle = true, -- デバッグ開始で開き、終了で閉じる
        },
      },

      ------------------------------------------------------------
      -- 変数値のインライン表示
      ------------------------------------------------------------
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled                  = true,
          enabled_commands         = true,
          highlight_changed_variables = true,
          show_stop_reason         = true,
        },
      },
    },

    config = function()
      local dap = require("dap")

      --------------------------------------------------------
      -- アダプタ設定: codelldb（Rust / C / C++）
      --------------------------------------------------------
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args    = { "--port", "${port}" },
        },
      }

      -- lldb-dap: PATH 解決を優先し、なければ macOS Homebrew パスにフォールバック
      local lldb_dap_cmd = vim.fn.exepath("lldb-dap")
      if lldb_dap_cmd == "" then
        lldb_dap_cmd = "/opt/homebrew/opt/llvm/bin/lldb-dap"
      end
      dap.adapters.lldb = {
        type    = "executable",
        command = lldb_dap_cmd,
        name    = "lldb",
      }

      --------------------------------------------------------
      -- Rust の起動設定
      --------------------------------------------------------
      dap.configurations.rust = {
        {
          name    = "Launch (codelldb)",
          type    = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input(
              "実行ファイル: ",
              vim.fn.getcwd() .. "/target/debug/",
              "file"
            )
          end,
          cwd            = "${workspaceFolder}",
          stopOnEntry    = false,
          sourceLanguages = { "rust" },
        },
      }

      --------------------------------------------------------
      -- キーマップ
      --------------------------------------------------------
      local map = vim.keymap.set
      map("n", "<F5>",       dap.continue,          { desc = "DAP: 続行" })
      map("n", "<F9>",       dap.toggle_breakpoint, { desc = "DAP: ブレークポイント切替" })
      map("n", "<F10>",      dap.step_over,         { desc = "DAP: ステップオーバー" })
      map("n", "<F11>",      dap.step_into,         { desc = "DAP: ステップイン" })
      map("n", "<F12>",      dap.step_out,          { desc = "DAP: ステップアウト" })
      map("n", "<leader>dR", dap.repl.open,         { desc = "DAP: REPL を開く" })
      map("n", "<leader>dU", function() require("dap-view").toggle() end, { desc = "DAP: UI 切替" })
      map("n", "<leader>dl", dap.run_last,          { desc = "DAP: 直前を再実行" })
    end,
  },
}
