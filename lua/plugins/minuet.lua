-- =============================================================================
-- minuet-ai.nvim: 手元のモデル（ollama の qwen2.5-coder:1.5b-base）で薄い候補（ghost text）を出す
-- =============================================================================
-- 外の API には送らない（localhost:11434 の ollama だけ）。
-- ollama は brew services（launchd）で常駐。待機中は数十 MB、モデル（約 1.1 GB）は
-- 使ったときだけ読み込まれ、5 分使わないと ollama が自分で外す。
--
-- キーマップ（挿入モード。blink が <C-f>/<C-e>/<Tab> を使うので重ならないキーにした）:
--   <C-l>      -> 候補を採用
--   <C-]>      -> 候補を消す（打ち続けても消える）
--   <leader>ta -> AI 補完のオン・オフ（既定はオン。vim.g.minuet_enabled、切り替えは snacks.lua）
-- 止める: brew services stop ollama（モデルごと消すなら ollama rm qwen2.5-coder:1.5b-base）
-- =============================================================================

return {
  "milanglacier/minuet-ai.nvim",
  event = "InsertEnter",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    provider = "openai_fim_compatible",
    n_completions = 1, -- 手元のモデルなので 1 つで十分（速さ優先）
    context_window = 1024, -- カーソルの前後から送る文字数
    throttle = 400,
    debounce = 300, -- 入力が止まってから頼むまで (ms)
    request_timeout = 5,
    -- <leader>ta で消したら頼まない（minuet 自体の切り替えはバッファごとなので、全体はこちらで）
    enable_predicates = { function() return vim.g.minuet_enabled ~= false end },
    provider_options = {
      openai_fim_compatible = {
        api_key = "TERM", -- ollama は鍵が要らない。必ずある環境変数の名前を入れておく
        name = "Ollama",
        end_point = "http://localhost:11434/v1/completions",
        model = "qwen2.5-coder:1.5b-base",
        -- 空行で止める（小さいモデルは関数の後ろに次の関数まで書き足しがち）。temperature 0 で一番ありそうな続きだけ
        optional = { max_tokens = 64, temperature = 0, stop = { "\n\n" } },
      },
    },
    virtualtext = {
      auto_trigger_ft = { "*" },
      auto_trigger_ignore_ft = { "snacks_picker_input", "snacks_terminal", "markdown", "text", "gitcommit" },
      keymap = {
        accept = "<C-l>",
        dismiss = "<C-]>",
      },
      show_on_completion_menu = true, -- blink のメニューが出ていても候補を出す
    },
  },
  config = function(_, opts)
    require("minuet").setup(opts)
    -- InsertEnter で読むので、開いてあるバッファには minuet の FileType での自動オンが届かない。同じことをここで
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[b].buflisted and not vim.tbl_contains(opts.virtualtext.auto_trigger_ignore_ft, vim.bo[b].filetype) then
        vim.b[b].minuet_virtual_text_auto_trigger = true
      end
    end
  end,
}
