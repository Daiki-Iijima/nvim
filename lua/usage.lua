-- =============================================================================
-- 使った記録（手元だけ。外には送らない）
-- =============================================================================
-- <leader> 系のキー・プラグインのキー（desc 付きの全体キー）・打ったコマンド（:Xxx）の
-- 「名前と回数」だけを日付ごとに数え、終了時に ~/.local/state/nvim/usage.jsonl へ追記する。
-- 打った文字・コマンドの引数・編集の中身は残さない。
-- :UsageReport [日数] で多い順と、使っていないキー・コマンドの一覧を出す。
-- =============================================================================

local M = {}

local path = vim.fn.stdpath("state") .. "/usage.jsonl"
local counts = {} -- ["日付\t種類\tモード\t名前"] = 回数（このセッションの分）
local known = {} -- ["モード\t名前"] = 説明（今張られている、数えているキー）
local last = {}

local function bump(kind, mode, name)
  local id = os.date("%Y-%m-%d") .. "\t" .. kind .. "\t" .. mode .. "\t" .. name
  -- shortcut: lazy.nvim の遅延キーは初回だけ「仮のキー→本物のキー」と 2 回呼ばれるので、50ms 以内の同じキーは 1 回に数える
  local now = vim.uv.hrtime()
  if last[id] and now - last[id] < 5e7 then return end
  last[id] = now
  counts[id] = (counts[id] or 0) + 1
end

-- " ff" や "<Leader>ff" を "<leader>ff" にそろえる
local function norm(lhs)
  local k = vim.fn.keytrans(vim.keycode(lhs))
  for _, p in ipairs({ { vim.g.mapleader, "<leader>" }, { vim.g.maplocalleader, "<localleader>" } }) do
    local lead = p[1] and vim.fn.keytrans(p[1])
    if lead and lead ~= "" and k:sub(1, #lead) == lead and #k > #lead then return p[2] .. k:sub(#lead + 1) end
  end
  return k
end

function M.setup()
  -- vim.keymap.set を包んで、数えるキーだけ「数えてから元の動き」にする（lazy.nvim の keys も snacks の toggle もここを通る）
  local set = vim.keymap.set
  vim.keymap.set = function(modes, lhs, rhs, opts)
    opts = opts or {}
    local name = norm(lhs)
    local desc = opts.desc or ""
    local leader = name:find("^<leader>") or name:find("^<localleader>")
    local global_desc = opts.buffer == nil and opts.buf == nil and desc ~= ""
    if not (leader or global_desc) or name:find("^<Plug>") or desc:find("which-key", 1, true)
      or (type(rhs) == "string" and opts.expr) then
      return set(modes, lhs, rhs, opts)
    end
    local mode = type(modes) == "table" and table.concat(modes) or modes
    known[mode .. "\t" .. name] = desc ~= "" and desc or (type(rhs) == "string" and rhs or "")
    local wrapped
    if type(rhs) == "function" then
      wrapped = function(...)
        bump("key", mode, name)
        return rhs(...)
      end
    else
      -- 文字列のキーは「同じ文字列を返す expr マップ」にして、動きを変えずに数える
      wrapped = function()
        bump("key", mode, name)
        return rhs
      end
      opts = vim.tbl_extend("force", opts, { expr = true, replace_keycodes = true })
    end
    return set(modes, lhs, wrapped, opts)
  end

  local group = vim.api.nvim_create_augroup("usage_log", {})
  -- コマンドは名前だけ数える（引数は残さない）。大文字で始まるもの＝プラグインと自前のコマンドだけ
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      if vim.fn.getcmdtype() ~= ":" or vim.v.event.abort then return end
      local ok, cmd = pcall(vim.api.nvim_parse_cmd, vim.fn.getcmdline(), {})
      if ok and cmd.cmd:find("^%u") then bump("cmd", ":", cmd.cmd) end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.flush })
  vim.api.nvim_create_user_command("UsageReport", function(o) M.report(tonumber(o.args)) end,
    { nargs = "?", desc = "使った記録: 多い順と使っていないキー・コマンド（引数: 直近の日数）" })
end

function M.flush()
  if next(counts) == nil then return end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local f = io.open(path, "a")
  if not f then return end
  for id, n in pairs(counts) do
    local date, kind, mode, name = id:match("^(.-)\t(.-)\t(.-)\t(.*)$")
    f:write(vim.json.encode({ date = date, type = kind, mode = mode, name = name, count = n }), "\n")
  end
  f:close()
  counts = {}
end

function M.report(days)
  local since = days and os.date("%Y-%m-%d", os.time() - days * 86400) or ""
  local total = {} -- ["種類\tモード\t名前"] = 回数
  local function add(date, kind, mode, name, n)
    if date < since then return end
    local id = kind .. "\t" .. mode .. "\t" .. name
    total[id] = (total[id] or 0) + n
  end
  local f = io.open(path, "r")
  if f then
    for line in f:lines() do
      local ok, r = pcall(vim.json.decode, line)
      if ok and type(r) == "table" and r.date then add(r.date, r.type, r.mode, r.name, r.count) end
    end
    f:close()
  end
  for id, n in pairs(counts) do
    local date, kind, mode, name = id:match("^(.-)\t(.-)\t(.-)\t(.*)$")
    add(date, kind, mode, name, n)
  end

  local used = {}
  for id, n in pairs(total) do table.insert(used, { id = id, n = n }) end
  table.sort(used, function(a, b) return a.n ~= b.n and a.n > b.n or a.id < b.id end)

  local lines = { "# 使った記録" .. (days and ("（直近 " .. days .. " 日）") or "（全期間）"), "", "記録: " .. path, "",
    "## 使ったもの（多い順）", "" }
  for _, u in ipairs(used) do
    local kind, mode, name = u.id:match("^(.-)\t(.-)\t(.*)$")
    local desc = kind == "key" and known[mode .. "\t" .. name] or ""
    table.insert(lines, string.format("%6d  %-4s %-22s %s", u.n, mode, name, desc or ""))
  end

  table.insert(lines, "")
  table.insert(lines, "## 使っていないキー（今張られているもの。バッファごとのキーは一度張られたものだけ）")
  table.insert(lines, "")
  local unused = {}
  for k, desc in pairs(known) do
    if not total["key\t" .. k] then table.insert(unused, k:gsub("\t", " ") .. "  " .. desc) end
  end
  table.sort(unused)
  vim.list_extend(lines, unused)

  table.insert(lines, "")
  table.insert(lines, "## 使っていないコマンド")
  table.insert(lines, "")
  local cmds = {}
  for name in pairs(vim.api.nvim_get_commands({})) do
    if not total["cmd\t:\t" .. name] then table.insert(cmds, ":" .. name) end
  end
  table.sort(cmds)
  vim.list_extend(lines, cmds)

  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].modifiable = "nofile", "wipe", false
  vim.bo[buf].filetype = "markdown"
end

return M
