# dotfiles

![License](https://img.shields.io/github/license/ookuni-asset/dotfiles)
![Nix](https://img.shields.io/badge/built%20with-Nix-5277C3?logo=nixos&logoColor=white)

## 環境

- macOS (Apple Silicon)
- Nix (Determinate Nix)
- home-manager
- Shell: zsh

## セットアップ手順

### 0. Homebrewのインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Apple Silicon Macの場合、インストール後にPATHを通す必要がある：

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 1. Nixのインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. home-managerのインストール

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### 3. このリポジトリをclone

```bash
git clone https://github.com/ookuni-asset/dotfiles.git ~/dotfiles
```

> 他の人が利用する場合は、自分のフォーク先URLに置き換えてください。

### 4. シンボリックリンクを張る

```bash
ln -sf ~/dotfiles/home.nix ~/.config/home-manager/home.nix
```

> `home.username` と `home.homeDirectory` は `$USER` / `$HOME` から自動で決まるため、書き換えは不要です。

### 5. 適用

```bash
home-manager switch
```

## Homebrewの管理（Brewfile）

GUIアプリはHomebrewで管理し、Brewfileをdotfilesで管理する。

### 現在の環境からBrewfileを生成

```bash
brew bundle dump --file=~/dotfiles/Brewfile
```

### 新しいMacで復元する場合

```bash
brew bundle install --file=~/dotfiles/Brewfile
```

## 管理しているもの

| ファイル | 内容 |
|---|---|
| `home.nix` | インストールパッケージ・Emacs設定・init.el・Karabiner-Elementsのルール定義 |
| `Brewfile` | HomebrewのGUIアプリ |

### Karabiner-Elementsのルール

`home.nix`は`~/.config/karabiner/assets/complex_modifications/`配下にルール定義(JSON)だけを配置する。`~/.config/karabiner/karabiner.json`本体はKarabiner-Elements自身が実行時に書き換える状態ファイルを兼ねるため、Nixでは管理しない。

新しいMacでは、`home-manager switch`適用後にKarabiner-Elementsの Preferences → Complex Modifications → Add rule で該当ルールを一度だけ手動で有効化する。

### yaziの使い方

yaziはターミナルファイラー。`home.nix`でEmacs風キーバインドの追加や、Enter時にVimのnetrwが暴発する問題の修正(smart-enterプラグイン)などをカスタマイズしている。

#### 上下左右移動

| 操作 | キー |
|---|---|
| 上へ | `k` / `↑` / `Ctrl+p`(Emacs風・本設定で追加) |
| 下へ | `j` / `↓` / `Ctrl+n`(Emacs風・本設定で追加) |
| 親ディレクトリへ戻る | `h` / `←` / `Ctrl+b`(Emacs風・本設定で追加) |
| ディレクトリに入る / ファイルを開く | `l` / `→` / `Ctrl+f`(Emacs風・本設定で追加) / `Enter` |

`Enter`はディレクトリかファイルかを自動判別する(smart-enterプラグイン)。ディレクトリなら中へ入り、ファイルなら開く。

#### ファイルパスをコピーする

ホバー中(またはVisualモードで選択中)のファイルの上で `c` → `c`(cを2回)と押す。ファイルの絶対パスがクリップボードにコピーされる。他のアプリやターミナルで`Cmd+V`すれば貼り付けられる。

似たコマンドとして、ディレクトリのパスだけが欲しいときは `c` → `d`、ファイル名だけなら `c` → `f`。

#### ファイル名で検索する(ディレクトリ配下を再帰的に)

1. `s` を押す(画面下に入力欄が出る)
2. 探したいファイル名の一部(正規表現も使える)を入力して `Enter`
3. カレントディレクトリ配下を再帰的に検索した結果が、新しい一覧画面として表示される。この中は通常のファイル一覧と同じくj/k等で移動でき、Enterで開ける
4. 検索結果から抜けて元の一覧に戻るには `Ctrl+s`

例: 拡張子が`.go`のファイルだけ探したいなら、入力欄に `\.go$` と入力する。

#### ファイルの中身(文字列)を検索する

1. `S` を押す(`s`と同じ入力欄が出る)
2. 探したい文字列(正規表現も使える)を入力して `Enter`
3. その文字列を**含んでいるファイルの一覧**(ripgrepによる高速検索。`.gitignore`は自動的に無視される)が表示される
4. 目的のファイルを選んで`Enter`で開く

注意: ここで表示されるのは「ヒットしたファイルの一覧」までで、ファイル内の該当行までは自動でジャンプしない。開いた後は、そのエディタ側の検索機能(vi系なら`/文字列`、Emacsなら`C-s`)で該当行を探す。

例(関数の定義を探す): Goのコードで`handleRequest`という関数がどこにあるか探したい場合、`S` → `func handleRequest` と入力して`Enter`。この文字列を含むファイル(=その関数が定義/参照されているファイル)が一覧に出る。

#### ファイル/ディレクトリへ一気にジャンプする

- `z`: fzf(あいまい検索)でカレントディレクトリ配下のファイル/ディレクトリを検索し、選んだ先へジャンプする
- `Z`: zoxide(これまでよく`cd`したディレクトリの履歴)からあいまい検索して、選んだディレクトリへジャンプする

#### 今表示されている一覧を絞り込む/その場で検索する

- `f`: カレントディレクトリの一覧を、入力した文字でリアルタイムに絞り込む(再帰検索はしない)。`Esc`で解除
- `/` → 文字列入力 → `Enter`: vimの`/`と同じ感覚で、現在の一覧内を検索してカーソルをジャンプさせる。`n`/`N`で次/前の一致へ移動

## パッケージを追加したいとき

`home.nix` の `home.packages` に追記して：

```bash
home-manager switch
```
