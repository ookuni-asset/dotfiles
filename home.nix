{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ty";
  home.homeDirectory = "/Users/ty";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    awscli2  # AWS CLIツール。S3やEC2などAWSサービスをターミナルから操作する
    bat      # catコマンドの強化版。シンタックスハイライトと行番号表示つき
#    emacs   # カスタマイズした状態でインストールするためにprograms.emacsで設定
    eza      # lsコマンドの強化版。色分け表示やgitステータス表示に対応
    fd       # findコマンドの高速版。シンプルな構文でファイル検索ができる
    fzf      # ファジーファインダー。コマンド履歴やファイルをインタラクティブに絞り込む
    gh       # GitHub CLI。PRの作成やIssueの管理をターミナルから行う
    glow     # ターミナル上でMarkdownをレンダリングしてプレビューする
    nkf      # 文字コード変換ツール。Shift_JISやEUC-JPなど日本語の文字コードを判定・変換する
    nodejs   # JavaScriptのランタイム。npm/npxも含む
    ripgrep  # grepコマンドの高速版。.gitignoreを自動で尊重してくれる
    tig      # gitのTUIフロントエンド。ログやdiffをターミナル上でビジュアルに確認する
    tree     # ディレクトリ構造をツリー形式で表示する
    uv       # Pythonのパッケージ・仮想環境マネージャー。pipより大幅に高速
    wget     # URLを指定してファイルをダウンロードする
    zoxide   # cdコマンドの強化版。過去の移動履歴から頻度の高いディレクトリにジャンプできる
  ];

  home.file.".tigrc".text = ''
    set vertical-split = no
  '';


  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.markdown-mode
      epkgs.catppuccin-theme # cmuxで使っているテーマ、Catppuccin Mochaに合わせる
    ];
  };

  home.file.".emacs.d/early-init.el".text = ''
    ;; Superset等一部の端末で、起動時のDA/背景色問い合わせへの応答が
    ;; ファイルバッファの先頭に誤挿入される問題を回避するため、
    ;; ターミナル機能の自動検出（エスケープシーケンス問い合わせ）を無効化する
    (setq xterm-extra-capabilities nil)
  '';

  home.file.".emacs.d/init.el".text = ''
    ;; C-h を Backspace に変更
    (global-set-key (kbd "C-h") 'delete-backward-char)
  
    ;; Catppuccin Mocha テーマ
    (load-theme 'catppuccin :no-confirm)
    (setq catppuccin-flavor 'mocha)
    (catppuccin-reload)
  
    ;; フォント（JetBrains Mono はcmuxと同じ）
    (set-face-attribute 'default nil
                        :family "JetBrainsMono Nerd Font"
                        :height 140)
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ty/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
