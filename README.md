# dotfiles

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
git clone git@github.com:ookuni-asset/dotfiles.git ~/dotfiles
```

### 4. シンボリックリンクを張る

```bash
ln -sf ~/dotfiles/home.nix ~/.config/home-manager/home.nix
```

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
| `home.nix` | インストールパッケージ・Emacs設定・init.el |
| `Brewfile` | HomebrewのGUIアプリ |

## パッケージを追加したいとき

`home.nix` の `home.packages` に追記して：

```bash
home-manager switch
```
