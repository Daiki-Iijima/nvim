local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leaderキー
vim.g.mapleader = " "

-----------------------------------------------------
-- 基本操作
-----------------------------------------------------
map("n", "<leader>w", ":w<CR>", opts)       -- 保存
map("n", "<leader>x", ":wq<CR>", opts)      -- 保存して終了
map("n", "<leader>q", ":q<CR>", opts)       -- 終了
map("n", "<leader>Q", ":q!<CR>", opts)      -- 強制終了

-----------------------------------------------------
-- ウィンドウ / バッファ移動
-----------------------------------------------------
map("n", "<leader>h", "<C-w>h", opts)
map("n", "<leader>j", "<C-w>j", opts)
map("n", "<leader>k", "<C-w>k", opts)
map("n", "<leader>l", "<C-w>l", opts)

-- リサイズ（Ctrl + 矢印）
map("n", "<C-Up>", ":resize -2<CR>", opts)
map("n", "<C-Down>", ":resize +2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-----------------------------------------------------
-- 編集まわり
-----------------------------------------------------
-- バックスペース・改行設定はinit.lua内に保持
-- “削除してもヤンクしない”挙動
map({ "n", "x" }, "d", '"_d', opts)
map({ "n", "x" }, "D", '"_D', opts)
map("n", "x", '"_x', opts)
map("x", "p", '"_dP', opts)

-----------------------------------------------------
-- 移動の自然化（論理行 → 画面行）
-----------------------------------------------------
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)
map("n", "gj", "j", opts)
map("n", "gk", "k", opts)

-----------------------------------------------------
-- Visualモード,Nomalモード便利化
-----------------------------------------------------
map("v", "<S-h>", "^", opts)
map("v", "<S-l>", "$", opts)
map("n", "<S-h>", "^", opts)
map("n", "<S-l>", "$", opts)

-----------------------------------------------------
-- Insertモード
-----------------------------------------------------
map("i", "jj", "<Esc>", opts)
map("i", "<C-c>", "<Esc>", opts)

-----------------------------------------------------
-- ターミナル操作の快適化
-----------------------------------------------------

-- ターミナルを下に開いてすぐ入力モードにする
vim.keymap.set("n", "<leader>t", function()
  vim.cmd("botright 15split | terminal")  -- 下に高さ15行で開く
  vim.cmd("startinsert")                  -- 自動で入力モードへ
end, { desc = "Open terminal below" })

-- <Esc> でノーマルモードに戻る（terminalモード用）
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal insert mode" })

-- ノーマルモードで "qq" を押すとターミナルを閉じる
vim.keymap.set("t", "qq", [[<C-\><C-n>:q!<CR>]], { desc = "Close terminal quickly" })
