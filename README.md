# dotfiles

## 環境

- macOS (Apple Silicon)
- Nix (Determinate Nix)
- home-manager
- Shell: zsh

## セットアップ手順

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
git clone git@github.com:<ユーザー名>/dotfiles.git ~/dotfiles
```

### 4. シンボリックリンクを張る

```bash
ln -sf ~/dotfiles/home.nix ~/.config/home-manager/home.nix
```

### 5. 適用

```bash
home-manager switch
```

## 管理しているもの

| ファイル | 内容 |
|---|---|
| `home.nix` | インストールパッケージ・Emacs設定・init.el |

## パッケージを追加したいとき

`home.nix` の `home.packages` に追記して：

```bash
home-manager switch
```
