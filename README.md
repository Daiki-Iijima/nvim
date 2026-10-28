# nvim

Neovim 0.12 + lazy.nvim の設定。`<leader>` はスペース、`<localleader>` はカンマ。

## 入口は 3 つ

1. **探す** … `<leader><space>`（ファイル）・`<leader>/`（文字列）・`<leader>f…`（snacks の picker）
2. **コードの操作** … Neovim 0.12 の既定のキー（`gr*`・`K`・`[d` `]d`）
3. **それ以外** … コマンドパレット `<leader>:`（コマンド一覧）／`<leader>?`（キー一覧）

## 早見表

`:Cheatsheet` で同じ表が浮いた窓に出る（この README の下の表を読んでいる）。

<!-- cheatsheet:start -->
| キー | すること |
| --- | --- |
| `<leader><space>` | ファイルを探す（最近・バッファ優先） |
| `<leader>/` | 文字列をプロジェクト全体から探す |
| `<leader>ff` / `fr` / `fb` | ファイル / 最近のファイル / バッファ |
| `<leader>fd` / `fs` | 診断の一覧 / シンボル |
| `<C-n>` | ファイルエクスプローラー |
| `gd` | 定義へ |
| `grr` / `gri` | 参照 / 実装 |
| `grn` | 名前を変える |
| `gra` | コードアクション |
| `K` | ホバー（日本語。`gK` は原文） |
| `[d` / `]d` | 前 / 次の診断へ |
| `<leader>ce` | 診断の詳細を日本語で |
| `<leader>cf` | フォーマット |
| `<leader>gg` | LazyGit |
| `[g` / `]g` | 前 / 次の変更箇所へ |
| `<leader>gs` / `gr` | 変更（hunk）をステージ / 元に戻す |
| `<leader>gp` | 変更の差分を見る |
| `<leader>aa` | omp を開く / 隠す |
| `<leader>at` | カーソル位置 / 選択を omp に送る |
| `<leader>t…` | 切り替え（`ts` スペル・`tw` 折り返し・`td` 診断・`th` インレイヒント） |
| `S` | Flash ジャンプ（2 文字 + ラベル） |
| `<C-_>`（Ctrl+/） | コメントの切り替え |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | ウィンドウ / tmux のペインを移動 |
| `<leader>w` / `<leader>q` | 保存 / 閉じる |
| `<leader>:` | コマンドパレット（キーを外したものはここから） |
| `<leader>?` | キー一覧 |
| `:Cheatsheet` | この表 |
<!-- cheatsheet:end -->

## `<leader>` のグループ

| グループ | 中身 |
| --- | --- |
| `f` 探す | `ff` `fg` `fr` `fb` `fh` `fd` `fD` `fs` `fq` `ft`(TODO) `fy`(ヤンク履歴) |
| `g` Git | `gg` `gs` `gr` `gS` `gR` `gu` `gp` `gb` `gB` `gd` |
| `c` コード | `cf` フォーマット・`ce` 診断の詳細・`cl` lint・`cR` 一括置換 |
| `a` AI (omp) | `aa` `at` `av` `af` `ap` |
| `t` 切り替え | `ts` `tw` `tn` `td` `th` |
| `l` 言語ごと | Rust: `lm` `lo` `lp` `lr` `ld` `le` |

LearnHarness は `<localleader>`（`,t` `,h` `,s` `,o` `,n` `,d`）と `<A-j>` `<A-k>`。

## キーを外してコマンドで呼ぶもの

`<leader>:` で名前を打てば出る。

| もの | コマンド |
| --- | --- |
| 翻訳 | `:Translate JA`（ビジュアルなら `:'<,'>Translate JA`）・`:Translate JA -output=insert` |
| コード実行 | `:RunCode`・`:RunCode 引数` |
| 線で図を描く | `:VennToggle` |
| 加算・切り替え（日付・true/false など） | `:DialIncrement`・`:DialDecrement`（`<C-a>` `<C-x>` は標準に戻した） |
| package.json | `:PackageInfoToggle`・`:PackageInfoUpdate`・`:PackageInfoInstall` など |
| Cargo.toml | `:Crates toggle`・`:Crates update_crate` など |
| デバッグ | `:DapToggleRepl`・`:DapViewToggle`・`:DapRunLast`（`<F5>` `<F9>`〜`<F12>` は残す） |
| スクラッチ | `:Scratch` |

## 使った記録

`<leader>` 系のキー・プラグインのキー・`:Xxx` のコマンドの「名前と回数」だけを日付ごとに数え、
終了時に `~/.local/state/nvim/usage.jsonl` へ追記する（手元だけ。打った文字・引数・編集の中身は残さない）。

- `:UsageReport` … 全期間の多い順と、使っていないキー・コマンドの一覧
- `:UsageReport 14` … 直近 14 日だけ
