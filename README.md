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

## パッケージを追加したいとき

`home.nix` の `home.packages` に追記して：

```bash
home-manager switch
```
