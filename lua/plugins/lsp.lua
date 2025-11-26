return {



  --------------------------------------------------------------------
  -- LSP 共通設定 + 各言語セットアップ
  --------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- ここで Neovim 組み込み LSP の設定を流すだけ
      -- ※ lspconfig の `require("lspconfig")` はどこでも呼ばない
      require("lang._loader").setup()
    end,
  },

  --------------------------------------------------------------------
  -- nvim-cmp（補完）
  --------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- 表示されるウィンドウの候補数の長さを制限
      vim.o.pumheight = 10

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
        }),

        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },

        window = {
          completion = {
            winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:None",
            max_height = 10,
          },
          documentation = cmp.config.window.bordered({
            max_width = 60,
            max_height = 15,
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,Search:None",
          }),
        },

        formatting = {
          -- 表示するカラム順を指定（名前 → 種別アイコン）
          fields = { "abbr", "kind" },

          -- lspkind で kind カラムだけを装飾
          format = lspkind.cmp_format({
            mode = "symbol", -- ← アイコンだけにする（"symbol_text" だと文字もつく）
            maxwidth = 40,
            ellipsis_char = "…",
          }),
        },

        -- たとえば「2文字以上入力したら補完開始」したいならこんなのもアリ
        -- completion = {
        --   keyword_length = 2,
        -- },
      })
    end,
  },

  --------------------------------------------------------------------
  -- Treesitter
  --------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "swift", "lua", "json" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  --------------------------------------------------------------------
  -- Conform（フォーマッタ統合）
  --------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
      formatters_by_ft = {}, -- lang 側で swift / lua を足していく
    },
  },
}
