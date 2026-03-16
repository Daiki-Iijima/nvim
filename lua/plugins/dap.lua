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
--   <leader>dU   -- DAP UI の表示切替
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
      -- DAP UI
      ------------------------------------------------------------
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap    = require("dap")
          local dapui  = require("dapui")

          dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
            layouts = {
              {
                elements = {
                  { id = "scopes",      size = 0.4 },
                  { id = "breakpoints", size = 0.15 },
                  { id = "stacks",      size = 0.25 },
                  { id = "watches",     size = 0.2 },
                },
                size = 40,
                position = "left",
              },
              {
                elements = {
                  { id = "repl",    size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                size = 10,
                position = "bottom",
              },
            },
          })

          -- デバッグ開始/終了時に UI を自動開閉
          dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
          dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
        end,
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

      -- macOS: lldb-dap（Homebrew LLVM）をフォールバックとして追加
      dap.adapters.lldb = {
        type    = "executable",
        command = "/opt/homebrew/opt/llvm/bin/lldb-dap",
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
      map("n", "<leader>dU", function() require("dapui").toggle() end, { desc = "DAP: UI 切替" })
      map("n", "<leader>dl", dap.run_last,          { desc = "DAP: 直前を再実行" })
    end,
  },
}
