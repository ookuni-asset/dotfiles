# herdr ショートカット チートシート

herdr のキーバインドは `~/.config/herdr/config.toml`（このリポジトリの `home.nix` が
home-manager 経由で生成）で定義している。デフォルト設定の全文は
`herdr --default-config` で確認できる。

**プレフィックスキーは `Ctrl+z`**（herdr のデフォルトは `Ctrl+b` だが変更済み）。
以下の表の `prefix + X` は「`Ctrl+z` を押してから `X` を押す」という意味。

迷ったら `prefix + ?` でアプリ内ヘルプが開く。

## ワークスペース（スペース）

| キー | 動作 |
| --- | --- |
| `prefix + w` | ワークスペース一覧から選択 |
| `prefix + Shift+n` | 新規ワークスペース |
| `prefix + Shift+w` | ワークスペース名の変更 |
| `prefix + Shift+d` | ワークスペースを閉じる（確認あり） |
| `prefix + Shift+g` | 新規 git worktree |
| `prefix + g` | navigate（goto）モードに入る |

## タブ

| キー | 動作 |
| --- | --- |
| `prefix + c` | 新規タブ（名前を聞かれる） |
| `prefix + n` | 次のタブ |
| `prefix + p` | 前のタブ |
| `prefix + 1`〜`9` | 番号でタブを切り替え |
| `prefix + Shift+t` | タブ名の変更 |
| `prefix + Shift+x` | タブを閉じる |

## ペイン

| キー | 動作 |
| --- | --- |
| `prefix + v` | 縦分割 |
| `prefix + -` | 横分割 |
| `prefix + h` / `j` / `k` / `l` | 左 / 下 / 上 / 右のペインへフォーカス |
| `prefix + Tab` | 次のペインへ巡回 |
| `prefix + Shift+Tab` | 前のペインへ巡回 |
| `prefix + z` | ズーム（全画面トグル） |
| `prefix + r` | リサイズモード |
| `prefix + x` | ペインを閉じる |
| `prefix + Shift+p` | ペイン名の変更 |
| `prefix + e` | スクロールバックをエディタで開く |

## 全体・セッション

| キー | 動作 |
| --- | --- |
| `prefix + ?` | ヘルプ |
| `prefix + b` | サイドバーの表示/非表示 |
| `prefix + s` | 設定画面 |
| `prefix + o` | 通知元のペインを開く |
| `prefix + q` | デタッチ（セッションは動き続ける） |
| `prefix + Shift+r` | config.toml をリロード |

## 自作のカスタムコマンド

| キー | 動作 |
| --- | --- |
| `prefix + d` | 「左 claude・中央シェル・右 yazi」（幅比 3:5:2）の3ペイン構成で新規ワークスペースを作成 |

`prefix + d` は `home.nix` の `herdrDevLayoutScript`（`herdr-dev-layout` コマンド）を
バックグラウンド実行している。レイアウトを変えたい場合はそのスクリプトを編集する。

## navigate モード中のキー（`prefix + g` のあと）

| キー | 動作 |
| --- | --- |
| `↑` / `↓` | ワークスペースの移動 |
| `h` / `j` / `k` / `l` | 左 / 下 / 上 / 右のペインへ移動（`←` `→` も可） |
| `1`〜`9` | 番号で直接選択 |
| `Esc` | navigate モードを抜ける |

## デフォルトでは未割り当ての主なアクション

必要になったら `config.toml` の `[keys]` に追加する。

- `previous_workspace` / `next_workspace` — 前後のワークスペースへ移動
- `previous_agent` / `next_agent` — 前後のエージェント行へ移動
- `focus_agent` — 番号でエージェントにフォーカス（例: `"prefix+alt+1..9"`）
- `switch_workspace` — 番号でワークスペースを切り替え（例: `"prefix+shift+1..9"`）
- `last_pane` — 直前のペインとの往復
- `open_worktree` / `remove_worktree` — worktree を開く / 削除する

## よく使う CLI

| コマンド | 動作 |
| --- | --- |
| `herdr` | セッションの起動またはアタッチ |
| `herdr status` | クライアントとサーバーの状態を表示 |
| `herdr --help` | サブコマンド一覧 |
| `herdr --default-config` | デフォルト設定（全キーバインド付き）を出力 |
| `herdr server reload-config` | 起動中のサーバーに config.toml を再読み込みさせる |
| `herdr config reset-keys` | config.toml をバックアップしてキーバインドをデフォルトに戻す |
| `herdr update` | 最新バージョンに更新 |
