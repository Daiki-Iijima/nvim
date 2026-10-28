-- package-info.nvim: package.json の依存関係管理
-- バージョン情報のインライン表示・アップデート・追加・削除など
-- npm / yarn / pnpm / bun を自動検出
--
-- キーは張らない。コマンドパレット（<leader>:）から呼ぶ:
--   :PackageInfoToggle         -- 依存バージョン情報の表示切替
--   :PackageInfoShowForce      -- 古い依存を表示（キャッシュを無視）
--   :PackageInfoUpdate         -- カーソル下の依存を最新に更新
--   :PackageInfoDelete         -- カーソル下の依存を削除
--   :PackageInfoInstall        -- 新しいパッケージを追加（名前を手入力）
--   :PackageInfoChangeVersion  -- カーソル下の依存のバージョンを変更

-- 対策: install 等が "Not in a JS/TS project" で止まる問題を回避する。
-- 原因は state.is_in_project が false のまま:
--   (1) lazy ロード時、既に開いてるバッファの BufEnter 検出が走り終えている
--   (2) ロックファイル未生成だとパッケージマネージャを検出できない
-- 押す直前に検出を強制実行し、それでもダメなら npm を既定にして初回を通す。
local function ensure_in_project()
  local ok_cfg, cfg = pcall(require, "package-info.config")
  local ok_st, state = pcall(require, "package-info.state")
  local ok_const, const = pcall(require, "package-info.utils.constants")
  if not (ok_cfg and ok_st and ok_const) then
    return
  end

  -- 今このバッファでパッケージマネージャ検出を強制実行（タイミング対策）
  pcall(cfg.__register_package_manager)

  -- ロックファイルがまだ無い → npm を既定にして初回 install を通す
  -- （install が `npm install` を実行し package-lock.json を生成する）
  if not state.is_in_project then
    cfg.options.package_manager = const.PACKAGE_MANAGERS.npm
    state.is_in_project = true
  end
end

return {
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = { "BufRead package.json" }, -- package.json を開いたらインライン表示
    cmd = {
      "PackageInfoToggle", "PackageInfoShow", "PackageInfoShowForce", "PackageInfoHide",
      "PackageInfoUpdate", "PackageInfoDelete", "PackageInfoInstall", "PackageInfoChangeVersion",
    },
    opts = {
      hide_up_to_date = false, -- 最新の依存も表示する
      icons = {
        enable = true,
        style = {
          up_to_date = "|  ",
          outdated = "|  ",
        },
      },
    },
    config = function(_, opts)
      local pi = require("package-info")
      pi.setup(opts)
      -- 依存を書き換えるコマンドは、実行の直前に ensure_in_project() を通すよう上書きする
      for name, fn in pairs({
        PackageInfoUpdate = "update",
        PackageInfoDelete = "delete",
        PackageInfoInstall = "install",
        PackageInfoChangeVersion = "change_version",
      }) do
        vim.api.nvim_create_user_command(name, function()
          ensure_in_project()
          pi[fn]()
        end, { desc = "Package: " .. fn })
      end
    end,
  },
}
