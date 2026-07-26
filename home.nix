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

  # Determinate NixがnixpkgsをFlakeHubのrolling channelに向けているため、
  # home-manager本体のバージョンと実際のnixpkgsバージョンが常にズレて見えて
  # 警告が出る。実害はないため抑制する。
  home.enableNixpkgsReleaseCheck = false;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    awscli2  # AWS CLIツール。S3やEC2などAWSサービスをターミナルから操作する
#    bat      # catコマンドの強化版。シンタックスハイライトと行番号表示つき
#    emacs   # カスタマイズした状態でインストールするためにprograms.emacsで設定
    eza      # lsコマンドの強化版。色分け表示やgitステータス表示に対応
    fd       # findコマンドの高速版。シンプルな構文でファイル検索ができる
    fzf      # ファジーファインダー。コマンド履歴やファイルをインタラクティブに絞り込む
    gh       # GitHub CLI。PRの作成やIssueの管理をターミナルから行う
    glow     # ターミナル上でMarkdownをレンダリングしてプレビューする
    nkf      # 文字コード変換ツール。Shift_JISやEUC-JPなど日本語の文字コードを判定・変換する
    nodejs   # JavaScriptのランタイム。npm/npxも含む
    ripgrep  # grepコマンドの高速版。.gitignoreを自動で尊重してくれる
    rustup   # Rustツールチェーンのバージョンマネージャー。uvのPython版に相当
    tig      # gitのTUIフロントエンド。ログやdiffをターミナル上でビジュアルに確認する
    tree     # ディレクトリ構造をツリー形式で表示する
    uv       # Pythonのパッケージ・仮想環境マネージャー。pipより大幅に高速
    wget     # URLを指定してファイルをダウンロードする
    zoxide   # cdコマンドの強化版。過去の移動履歴から頻度の高いディレクトリにジャンプできる
  ];

  home.file.".tigrc".text = ''
    set vertical-split = no
  '';

  # Karabiner-Elements: Supersetにフォーカスがある間だけ左OptionをEscapeとして送出する。
  # SupersetのターミナルはEscapeをMetaとして認識するため、Emacsでeglot/xref(M-.等)を
  # 左OptionキーをMeta代わりに使える感覚で使えるようにするための設定。
  #
  # 注意: karabiner.json本体(~/.config/karabiner/karabiner.json)はKarabiner-Elements自身が
  # 実行時に書き換える状態ファイル(プロファイル選択、ルールの有効/無効等)を兼ねているため、
  # home-managerでシンボリックリンク管理すると衝突する。そのため「インポート可能なルール定義」
  # として~/.config/karabiner/assets/complex_modifications/配下にのみ配置し、
  # 有効化はKarabiner-Elements側のPreferences → Complex Modifications → Add ruleで
  # 初回だけ手動で行う(この「どのルールが有効か」という状態自体はNixでは管理しない)。
  home.file.".config/karabiner/assets/complex_modifications/superset-left-option-to-escape.json".text = ''
    {
      "title": "Superset: 左OptionをMeta(Escape)にする",
      "rules": [
        {
          "description": "Supersetにフォーカスがある間だけ、左OptionキーをEscapeとして送出する",
          "manipulators": [
            {
              "type": "basic",
              "from": {
                "key_code": "left_option",
                "modifiers": { "optional": ["any"] }
              },
              "to": [
                { "key_code": "escape" }
              ],
              "conditions": [
                {
                  "type": "frontmost_application_if",
                  "bundle_identifiers": ["^com\\.superset\\.desktop$"]
                }
              ]
            }
          ]
        }
      ]
    }
  '';

  # Karabiner-Elements: CapsLockキーをControlとして使えるようにし、
  # CapsLock本来の機能(トグル)自体はどのキーからも発動しないようにする。
  # 物理ControlキーはそのままControlとして機能するため、変換は片方向のみでよい。
  #
  # 注意: 同じ内容を~/.config/karabiner/karabiner.json内のSimple Modifications
  # (GUIで手動設定したもの)にも残したままだと、こちらのComplex Modificationsルールと
  # 二重に変換されて意図通りに動かなくなる。このルールを有効化したら、
  # Karabiner-Elements Preferences → Devices → 対象キーボード → Simple modifications
  # 内の「left_control→caps_lock」「caps_lock→left_control」の2エントリは削除すること。
  #
  # 有効化はKarabiner-Elements側のPreferences → Complex Modifications → Add ruleで
  # 初回だけ手動で行う(superset-left-command-to-escapeと同様、この「どのルールが
  # 有効か」という状態自体はNixでは管理しない)。
  home.file.".config/karabiner/assets/complex_modifications/capslock-to-control.json".text = ''
    {
      "title": "CapsLockをControlにする(CapsLock機能自体は無効化、システム全体)",
      "rules": [
        {
          "description": "CapsLockキーをControlとして送出する(実際のCapsLockトグルは発動しない)",
          "manipulators": [
            {
              "type": "basic",
              "from": { "key_code": "caps_lock" },
              "to": [{ "key_code": "left_control" }]
            }
          ]
        }
      ]
    }
  '';

  home.file.".zshrc".text = ''
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    eval "$(direnv hook zsh)"
    eval "$(fzf --zsh)"
    eval "$(zoxide init zsh)"

    alias ll='eza -la --git'
    alias emacs='emacs -nw'

    # uv
    export PATH="/Users/ty/.local/bin:$PATH"

    # rust-study: cargo/rustcをNixビルドのコンテナ(Rustツールチェーンのみ)内で実行する。
    # 編集(Emacs/eglot/補完)はローカルのrustup/rust-analyzerで行い、
    # ビルド・実行だけコンテナに委譲する。globalの`cargo`は上書きしない。
    # `-C <path>` でカレントディレクトリ以外のプロジェクトも指定できる
    # (cargo本家の`-C`と同じ感覚で使える。未指定時は$PWDを使う)。
    # 詳細: rust-study/notes/07-dev-environment.md
    cargo-box() {
      local project_dir="$PWD"
      if [ "$1" = "-C" ]; then
        project_dir="$(cd "$2" 2>/dev/null && pwd)"
        if [ -z "$project_dir" ]; then
          echo "cargo-box: no such directory: $2" >&2
          return 1
        fi
        shift 2
      fi
      docker run --rm -it -v "$project_dir":/workspace -w /workspace cargo-box:latest cargo "$@"
    }
  '';


  # bat: SupersetのターミナルテーマがDracula(背景#282a36)のため、
  # 表示テーマも合わせる。batはDraculaテーマを標準でバンドルしているため、
  # 名前を指定するだけでよい。
  #
  # テーマ指定にはもう一つ理由があり、themeを明示しない場合batは背景が
  # ダーク/ライトどちらかを自動判定するためOSC 11(背景色問い合わせ)を
  # 端末に送る。Supersetはこの問い合わせに対する応答をbatが読み取る前に
  # 画面へそのまま描画してしまい、標準出力にエスケープ応答の文字列が
  # 混ざって表示される不具合があった。テーマを固定するとこの問い合わせ
  # 自体が発生しなくなり、この文字化けも同時に回避できる。
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.markdown-mode
      epkgs.rust-mode
      epkgs.catppuccin-theme # cmuxで使っているテーマ、Catppuccin Mochaに合わせる
      epkgs.corfu           # 補完ポップアップUI
      epkgs.corfu-terminal  # ターミナルEmacsでcorfuのポップアップを表示するために必要
      epkgs.orderless       # あいまい一致の補完スタイル
      epkgs.cape            # 補完ソース追加(ファイルパス等)
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

    ;; Rust: rust-mode + eglot(Emacs29+標準LSPクライアント)
    ;; rustup でインストールした rust-analyzer にPATHが通っていれば
    ;; eglot が自動で認識するため追加設定は不要。
    (require 'rust-mode)
    (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
    (add-hook 'rust-mode-hook 'eglot-ensure)
    (setq rust-format-on-save t)

    ;; 補完UI: corfu(ポップアップ) + orderless(あいまい一致) + cape(補完ソース追加)
    (require 'orderless)
    (setq completion-styles '(orderless basic)
          completion-category-defaults nil
          completion-category-overrides '((file (styles partial-completion))))

    (require 'corfu)
    (global-corfu-mode)
    (setq corfu-auto t
          corfu-auto-delay 0.1
          corfu-auto-prefix 1)

    ;; ターミナルEmacs(emacs -nw)ではcorfuのポップアップがGUIの子フレームに
    ;; 依存するため、corfu-terminal-modeを有効化しないと表示されない
    (require 'corfu-terminal)
    (corfu-terminal-mode +1)

    (require 'cape)
    (add-to-list 'completion-at-point-functions #'cape-file)
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
