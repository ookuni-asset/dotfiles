{ config, pkgs, ... }:

let
  # hunk: ターミナルdiffビューア(https://hunk.dev)。nixpkgs未収録のため、
  # hunk自身のflakeをbuiltins.getFlakeで直接参照している。lockファイルを
  # 介さないため、home-manager switchのたびにgithub:modem-dev/hunkの
  # 最新コミットを再取得する(バージョン固定はできない)。
  hunkFlake = builtins.getFlake "github:modem-dev/hunk";

  # Superset用: 左OptionキーをEmacsのMetaキーとして使うためのKarabinerルール生成。
  # 「Optionキー単体→Escapeキー単体」への単純な置き換えだと、Option押下と他キー押下が
  # 別々の独立したキーイベントとして送出されるため、同時押し(コンビネーション)として
  # ターミナルに伝わらないことがあった(ESC→キーの2打鍵は動くのに、Optionを押しっぱなし
  # にしたまま他のキーを押す同時押しだと動かない、という非対称な挙動になっていた)。
  # そこで、Option+個別キーの組み合わせごとに「ESC→そのキー」を1つのイベントとして
  # まとめて送出するルールを、対象キー分だけ生成する。加えてOption単体タップ時は
  # 従来通りEscapeとして機能するよう、lazy+to_if_aloneの組み合わせも残す。
  supersetCondition = {
    type = "frontmost_application_if";
    bundle_identifiers = [ "^com\\.superset\\.desktop$" ];
  };

  supersetMetaKeys =
    [ "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
      "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"
      "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
      "period" "comma" "slash" "hyphen" "equal_sign" "semicolon" "quote"
      "open_bracket" "close_bracket" "backslash" "grave_accent_and_tilde"
      "spacebar" "tab" "return_or_enter" "delete_or_backspace"
    ];

  supersetMetaManipulators = map (key: {
    type = "basic";
    from = {
      key_code = key;
      modifiers = { mandatory = [ "left_option" ]; optional = [ "any" ]; };
    };
    to = [
      { key_code = "escape"; }
      { key_code = key; }
    ];
    conditions = [ supersetCondition ];
  }) supersetMetaKeys;

  # herdr用: prefix+dで「左claude・中央シェル・右yazi(幅比3:5:2)」の
  # 3ペイン構成を持つ新規ワークスペースを作る。herdrのpane split --ratioは
  # 分割元(左側)ペインの取り分なので、まず0.3で切り出し、残り0.7を
  # さらに0.7142857(5/7)で切ることで全体比3:5:2を実現している。
  herdrDevLayoutScript = pkgs.writeShellScriptBin "herdr-dev-layout" ''
    set -euo pipefail

    cwd="''${HERDR_ACTIVE_PANE_CWD:-$HOME}"

    create=$(herdr workspace create --cwd "$cwd" --focus)
    p1=$(echo "$create" | jq -r '.result.root_pane.pane_id')

    s1=$(herdr pane split "$p1" --direction right --ratio 0.3)
    p2=$(echo "$s1" | jq -r '.result.pane.pane_id')

    s2=$(herdr pane split "$p2" --direction right --ratio 0.7142857)
    p3=$(echo "$s2" | jq -r '.result.pane.pane_id')

    herdr pane run "$p1" claude
    herdr pane run "$p3" yazi
  '';
in
{
  imports = [ hunkFlake.homeManagerModules.default ];

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
    ffmpeg   # 動画・音声の変換ツール。yt-dlpがMP3変換(音声抽出)時に内部で利用する
    fzf      # ファジーファインダー。コマンド履歴やファイルをインタラクティブに絞り込む
    gh       # GitHub CLI。PRの作成やIssueの管理をターミナルから行う
    glow     # ターミナル上でMarkdownをレンダリングしてプレビューする
    go       # Go言語のツールチェーン(コンパイラ・go fmt・go test等)
    gopls    # Go公式のLSPサーバー。Emacsのeglotから利用する
    herdr    # コーディングエージェント向けランタイム。ターミナルを常時稼働させ、どこでもエージェントを実行できる
    herdrDevLayoutScript # herdr prefix+d用: claude/シェル/yaziの3ペインworkspaceを自動生成
    jq       # JSONを整形・抽出するコマンドラインツール。herdr-dev-layoutがAPI応答のパースに使う
    nkf      # 文字コード変換ツール。Shift_JISやEUC-JPなど日本語の文字コードを判定・変換する
    nodejs   # JavaScriptのランタイム。npm/npxも含む
    ripgrep  # grepコマンドの高速版。.gitignoreを自動で尊重してくれる
    rustup   # Rustツールチェーンのバージョンマネージャー。uvのPython版に相当
    tig      # gitのTUIフロントエンド。ログやdiffをターミナル上でビジュアルに確認する
    tree     # ディレクトリ構造をツリー形式で表示する
    uv       # Pythonのパッケージ・仮想環境マネージャー。pipより大幅に高速
    wget     # URLを指定してファイルをダウンロードする
#    yazi     # レイアウトをカスタマイズした状態でインストールするためprograms.yaziで設定
    yt-dlp   # YouTube等の動画ダウンローダー。ffmpegと組み合わせてMP3抽出もできる
    zoxide   # cdコマンドの強化版。過去の移動履歴から頻度の高いディレクトリにジャンプできる
  ];

  home.file.".tigrc".text = ''
    set vertical-split = no
  '';

  # Karabiner-Elements: Supersetにフォーカスがある間、左OptionキーをEmacsのMetaキーとして
  # 使えるようにする。ルールの中身の生成ロジックは上のletブロック(supersetCondition /
  # supersetMetaKeys / supersetMetaManipulators)を参照。
  #
  # 以前は「Optionキー単体→Escapeキー単体」への単純置き換えだった(ファイル名
  # superset-left-option-to-escape.json)が、Option+他キーの同時押しがうまく伝わらない
  # 問題があったため、このルールに置き換えた。Karabiner-Elements側で古いルール
  # 「Superset: 左OptionをMeta(Escape)にする」が有効化されている場合は無効化し、
  # 代わりに下記の新しいルールを有効化すること。
  #
  # 注意: karabiner.json本体(~/.config/karabiner/karabiner.json)はKarabiner-Elements自身が
  # 実行時に書き換える状態ファイル(プロファイル選択、ルールの有効/無効等)を兼ねているため、
  # home-managerでシンボリックリンク管理すると衝突する。そのため「インポート可能なルール定義」
  # として~/.config/karabiner/assets/complex_modifications/配下にのみ配置し、
  # 有効化はKarabiner-Elements側のPreferences → Complex Modifications → Add ruleで
  # 初回だけ手動で行う(この「どのルールが有効か」という状態自体はNixでは管理しない)。
  home.file.".config/karabiner/assets/complex_modifications/superset-option-meta.json".text =
    builtins.toJSON {
      title = "Superset: 左OptionキーをMetaとして使う";
      rules = [
        {
          description = "Supersetにフォーカスがある間、左Optionを単体でタップしたらEscape、他のキーと同時押ししたらESC+そのキーをまとめて送出する(Emacsのeglot/xref等でM-.のようなMetaキー操作を使うため)";
          manipulators = [
            {
              type = "basic";
              from = {
                key_code = "left_option";
                modifiers = { optional = [ "any" ]; };
              };
              to = [
                { key_code = "left_option"; lazy = true; }
              ];
              to_if_alone = [
                { key_code = "escape"; }
              ];
              conditions = [ supersetCondition ];
            }
          ] ++ supersetMetaManipulators;
        }
      ];
    };

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
              "from": {
                "key_code": "caps_lock",
                "modifiers": { "optional": ["any"] }
              },
              "to": [{ "key_code": "left_control" }]
            }
          ]
        }
      ]
    }
  '';

  # Karabiner-Elements: 外付けキーボード(vendor_id 1241 / product_id 323。
  # left_option⇔left_commandの入れ替えを設定しているものと同一デバイス)専用に、
  # 物理左ControlキーをmacOSのfn(Globe)キーとして送出する。
  #
  # 背景: このデバイスでは物理CapsLockキーが既にControlとして機能する(上の
  # capslock-to-control.jsonルール、システム全体に適用)ため、物理左Controlキーが
  # 本来のControlとしては冗長になっていた。そこでこのキーボードに限り、
  # 物理左Controlキーをfnキーとして再利用する。
  #
  # device_ifで対象デバイスを絞っているため、他のキーボード(内蔵キーボード等)の
  # 左Controlキーには影響しない。
  #
  # 有効化はKarabiner-Elements側のPreferences → Complex Modifications → Add ruleで
  # 初回だけ手動で行う(他のComplex Modificationsルールと同様、この「どのルールが
  # 有効か」という状態自体はNixでは管理しない)。
  home.file.".config/karabiner/assets/complex_modifications/external-keyboard-leftcontrol-to-fn.json".text = ''
    {
      "title": "外付けキーボード限定: 物理左Controlキーをfnキーにする",
      "rules": [
        {
          "description": "外付けキーボード(vendor_id 1241 / product_id 323)でのみ、物理左Controlキーをfn(Globe)キーとして送出する",
          "manipulators": [
            {
              "type": "basic",
              "from": {
                "key_code": "left_control",
                "modifiers": { "optional": ["any"] }
              },
              "to": [{ "key_code": "fn" }],
              "conditions": [
                {
                  "type": "device_if",
                  "identifiers": [
                    { "vendor_id": 1241, "product_id": 323 }
                  ]
                }
              ]
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


  # hunk: git/AIエージェントとのレビュー用diffビューア。パッケージ本体は
  # 上のimportsで読み込んだ公式home-managerモジュール(programs.hunk)経由で
  # 導入する。
  programs.hunk = {
    enable = true;
    # 注意: enableGitIntegrationはprograms.git.settings.core.pagerを設定するだけで、
    # このリポジトリではprograms.git自体を有効化していないため実際には無効(no-op)。
    # gitのpagerとしてhunkを使う設定は `git config --global core.pager "hunk pager"` を
    # 手動実行して~/.gitconfig(home-manager管理外)に反映している。
    enableGitIntegration = true;
    enableClaudeIntegration = true; # ~/.claude/skills/hunk-reviewにレビュースキルをリンク
    settings = {
      theme = "dracula"; # bat/Supersetと合わせてDraculaテーマに統一
    };
  };

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

  # yazi: ターミナルファイラー。デフォルトは親ディレクトリ/カレント/プレビューの
  # 3ペイン表示だが、カレントディレクトリのファイル一覧だけを全幅で表示したいため
  # ratioで親ペインとプレビューペインの幅を0にする。
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        ratio = [ 0 1 0 ];
      };
    };
  };

  programs.emacs = {
    enable = true;
    # withMailutils = falseで、Emacs本体が依存するmailutils(movemail等メール機能用の
    # ライブラリ)をビルド対象から外している。メール機能は使っておらず、また現在の
    # nixpkgs rolling channelではmailutils-3.21がaarch64-darwinでリンクエラーにより
    # ビルドできない状態(libmu_sieve内でシンボル未解決)のため、無効化して回避する。
    # nixpkgs側で修正されたら、この行は不要になるかもしれない。
    package = pkgs.emacs.override { withMailutils = false; };
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.markdown-mode
      epkgs.rust-mode
      epkgs.go-mode
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

    ;; rust-study のように、トップレベルにworkspace用Cargo.tomlを置かず
    ;; 独立した複数crateがサブディレクトリに散らばっているリポジトリでは、
    ;; project.elのデフォルト(VCルート=.gitのある場所)のままだとeglotが
    ;; リポジトリ全体を1プロジェクトとして扱ってしまい、rust-analyzerが
    ;; 一部のcrate(Cargo.toml)しか検出しないことがある。
    ;; Cargo.tomlがあるディレクトリ自体をプロジェクト境界として認識させ、
    ;; crateごとに正しくスコープされたrust-analyzerが起動するようにする。
    (setq project-vc-extra-root-markers '("Cargo.toml"))
  
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

    ;; Go: go-mode + eglot(Emacs29+標準LSPクライアント)
    ;; NixでインストールしたgoplsにPATHが通っていれば
    ;; eglot が自動で認識するため追加設定は不要。
    (require 'go-mode)
    (add-hook 'go-mode-hook 'eglot-ensure)
    (add-hook 'before-save-hook 'gofmt-before-save)

    ;; interfaceのメソッド呼び出しからM-.すると宣言(interface側)にしか飛べないため、
    ;; 具体的な実装(struct側)に飛びたいときはこちらを使う。
    ;; 端末上ではC-iはTabと同じバイト(0x09)を送るため、実質C-c TABと同じキー
    ;; として扱われる点に注意。
    (global-set-key (kbd "C-c C-i") 'eglot-find-implementation)

    ;; M-. / M-, はOption+記号キーの同時押しになるため、herdr(Ghostty経由)では
    ;; 伝わらないことがある。C-c C-iと同じ理由で、Ctrlベースの確実に伝わる
    ;; キーにも同じコマンドを割り当てておく。
    (global-set-key (kbd "C-c .") 'xref-find-definitions)
    (global-set-key (kbd "C-c ,") 'xref-go-back)

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

    # herdr: prefixキーをCtrl+Bのデフォルトから、Ghosttyのタブ切り替え(Cmd+T)と
    # 衝突しないCtrl+Zに変更している。job control(SIGTSTP)のCtrl+Zとは競合するが、
    # job controlは使わない運用のため許容している。
    ".config/herdr/config.toml".text = ''
      onboarding = false

      [keys]
      prefix = "ctrl+z"

      # prefix+d: 左claude・中央シェル・右yazi(幅比3:5:2)の3ペイン構成で
      # 新規ワークスペースを作る。shellは検出したままバックグラウンドで
      # 実行され、ペイン自体の起動には関与しない(=herdr-dev-layoutの中で
      # 明示的にpane splitとpane runを行っている)。
      [[keys.command]]
      key = "prefix+d"
      type = "shell"
      command = "herdr-dev-layout"

      [ui]
      # 境界線を共有せず隙間を空けることで、フォーカス中のペインの境界を
      # 太く・見つけやすくする(線自体の太さを変える設定はherdrにないため)。
      pane_gaps = true
      # デフォルトのaccent(境界線・ハイライトの色)は紫系で、サイドバーの
      # 選択ハイライト等と色味が近く埋もれて見えるため、パレット内で
      # 最もコントラストの強い黄色(Catppuccin Mochaのyellowトークン)に
      # 上書きしてフォーカス中のペインを目立たせる。
      accent = "#f9e2af"

      [theme]
      # GhosttyとEmacsがCatppuccin Mochaなので揃える(herdrの組み込み
      # "catppuccin"テーマはMocha相当で、herdr自体のデフォルト値でもある)。
      name = "catppuccin"
      auto_switch = false
    '';

    # Ghostty: これまで~/.config/ghosttyを手動編集で管理していたが、
    # home.nixに移して他の設定と同様にNixで管理する。theme指定は
    # herdr/Emacsと揃えたCatppuccin Mocha。background/foreground/cursor-color
    # は手動運用時代からの上書きで、テーマ既定のbase(#1e1e2e)より一段暗い
    # crust(#11111b)を使う好みを引き継いでいる。
    ".config/ghostty/config".text = ''
      # フォント
      font-family = "JetBrains Mono"
      font-size = 16
      adjust-cell-height = 10%

      # テーマ(Catppuccin Mocha。背景色のみcrustトーンに独自上書き)
      theme = "Catppuccin Mocha"
      background = #11111b
      foreground = #cdd6f4
      cursor-color = #f5e0dc

      # 背景透過・ブラー
      background-opacity = 0.90
      background-blur-radius = 20

      # ウィンドウ
      window-padding-x = 10
      window-padding-y = 10
      window-padding-balance = true
      macos-titlebar-style = transparent
      macos-window-shadow = true
      mouse-hide-while-typing = true

      # 分割ペイン
      unfocused-split-opacity = 0.80
      unfocused-split-fill = #11111b
      split-divider-color = #45475a

      # スクロールバック
      scrollback-limit = 50000

      # 作業ディレクトリ
      working-directory = ~/code

      # metaキーを左optionに割り当てる
      macos-option-as-alt = left

      # 操作性
      copy-on-select = true
      clipboard-read = allow
      clipboard-write = allow
    '';

    # direnv: 本体はBrewfileでインストール(brew "direnv")しているが、
    # 設定ファイル(~/.config/direnv/direnvrc)はこれまで手動編集で
    # 管理していたためNix管理下に移す。layout_uvはuvでの.venv作成を
    # direnvのlayoutコマンドとして使えるようにするカスタム関数。
    ".config/direnv/direnvrc".text = ''
      layout_uv() {
        if [[ -d ".venv" ]]; then
          VIRTUAL_ENV="$(pwd)/.venv"
        fi

        if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
          log_status "No virtual environment found. Creating one with uv..."
          uv venv .venv
          VIRTUAL_ENV="$(pwd)/.venv"
        fi

        export VIRTUAL_ENV
        export PATH="$VIRTUAL_ENV/bin:$PATH"
        log_status "Using virtualenv: $VIRTUAL_ENV"
      }
    '';
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
