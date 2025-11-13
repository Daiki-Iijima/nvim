-- Lazy.nvimのパス
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 存在しない場合はGitHubからclone
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end

-- runtimepathに追加
vim.opt.rtp:prepend(lazypath)

-- 24bitカラーを有効にする
vim.opt.termguicolors = true

-- lua/keymaps.luaからnvimのkeymapを読み込む
require("keymaps")

-- lua/settings.luaからnvimの設定を読み込む
require("settings")

-- プラグインを読み込む
require("lazy").setup({
  spec = {
    { import = "plugins" },
  }
})
