-- =============================================================================
-- codecompanion.nvim: AI-powered coding companion
-- =============================================================================
-- GitHub Copilot をバックエンドとして使用し、AIチャットやインライン補完を行います。
-- コマンドや変数、コンテキストを補完する機能も nvim-cmp と連動します。
--
-- キーマップ:
--   <leader>aa -> CodeCompanion Actionsメニューを開く（ノーマル/ビジュアル）
--   <leader>ac -> CodeCompanion チャットウィンドウのトグル（ノーマル/ビジュアル）
--   <leader>ap -> CodeCompanion インラインアシスタントを開く（ノーマル/ビジュアル）
-- =============================================================================

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- アイコン用
  },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion アクション" },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion チャット切替" },
    { "<leader>ap", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "CodeCompanion インラインプロンプト" },
  },
  opts = {
    -- 旧バージョン用の設定（後方互換性のため）
    strategies = {
      chat = {
        adapter = "copilot", -- デフォルトのアダプター。 "anthropic" や "openai" に変更可能です
        keymaps = {
          send = {
            modes = {
              n = "<CR>",
              i = "<C-g>", -- <C-s> は tmux と競合するため <C-g> に変更
            },
          },
        },
      },
      inline = {
        adapter = "copilot",
      },
      agent = {
        adapter = "copilot",
      },
    },

    -- 新バージョン (v18.0.0以降) 用の設定
    interactions = {
      chat = {
        adapter = "copilot",
        keymaps = {
          send = {
            modes = {
              n = "<CR>",
              i = "<C-g>", -- <C-s> は tmux と競合するため <C-g> に変更
            },
          },
        },
      },
      inline = {
        adapter = "copilot",
      },
      agent = {
        adapter = "copilot",
      },
      cli = {
        agent = "claude_code", -- デフォルトの CLI エージェントとして claude_code を使用
      },
    },

    display = {
      chat = {
        window = {
          layout = "float",   -- チャット画面をポップアップ表示にする
          border = "rounded",  -- 枠線を丸くする
          width = 0.8,        -- 画面幅に対する比率（80%）
          height = 0.8,       -- 画面高に対する比率（80%）
        },
      },
    },

    adapters = {
      -- Anthropic (Claude) の個別設定を行う場合（環境変数 ANTHROPIC_API_KEY があればこのブロック自体不要です）
      -- anthropic = function()
      --   return require("codecompanion.adapters").extend("anthropic", {
      --     env = {
      --       api_key = "YOUR_API_KEY_HERE"
      --     },
      --   })
      -- end,

      -- OpenAI (GPT) の個別設定を行う場合（環境変数 OPENAI_API_KEY があればこのブロック自体不要です）
      -- openai = function()
      --   return require("codecompanion.adapters").extend("openai", {
      --     env = {
      --       api_key = "YOUR_API_KEY_HERE"
      --     },
      --   })
      -- end,

      -- Ollama (PCローカルで動かすLLM) を使用する場合（Ollamaがローカルで起動している必要があります）
      -- ollama = function()
      --   return require("codecompanion.adapters").extend("ollama", {
      --     schema = {
      --       model = {
      --         default = "llama3", -- ローカルにダウンロードしたモデル名（例: llama3, qwen2.5-coder 等）
      --       },
      --     },
      --   })
      -- end,
    },
  },
}
