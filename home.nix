{ config, pkgs, lib, ... }:

let

  username = "alex";
  homeDirectory = "/home/alex";
  defaultPkgs = with pkgs;
    [

      # UI
      brave
      calibre
      discord
      firefox
      fragments
      kooha
      obsidian
      slack
      vlc
      zoom-us
      zotero
      mixxx
      element-desktop

      # hacky stuff
      pre-commit
      tldr
      xclip
      yt-dlp
      radicle-node

      # dev toolchains
      nodejs
      nodePackages.typescript-language-server
      nodePackages.typescript
      nodePackages.prettier
      nodePackages.eslint
      lean4
      python
      gcc
      cargo
      rustc
      rust-analyzer
      # neovim dependencies
      fd
      ripgrep
      nil
      nixpkgs-fmt
    ] ++ (with pkgs.haskellPackages; [
      cabal2nix
      cabal-install
      ghc
      haskell-language-server
      hoogle
      nix-tree
      ihaskell
      haskell-ci
      fourmolu
    ]) ++ (with pkgs.python311Packages; [
      (llm.withPlugins {
        # llm-docs = true; # needs openAI key
        llm-groq = true;
        llm-jq = true;
        llm-ollama = true;
      })
    ]);
in {
  dconf = {
    enable = true;
    settings."org/gnome/desktop/calendar".show-weekdate = true;
  };
  programs = {
    # Let Home Manager install and manage itself:
    home-manager.enable = true;
    # autorandr.enable = true; #external monitor
    bash = {
      enable = true;
      profileExtra = ''
        if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
           GIT_PROMPT_ONLY_IN_REPO=1
           source $HOME/.bash-git-prompt/gitprompt.sh
        fi
      '';
    };
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
    git = {
      enable = true;
      userName = "Alex";
      userEmail = "alexeusgr@gmail.com";
      diff-so-fancy.enable = true;
      signing = {
        signByDefault = true;
        key = "603C BC84 E2C1 4092 A904  B9A0 17BD F408 11CF 970A";
      };
      extraConfig = {
        commit.gpgsign = true;
        tag.gpgsign = true;
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      };
    };
    gpg = { enable = true; };
    # Neovim is starting to get huge; should move to a separate file.
    neovim = {
      enable = true;
      coc.enable = false; # using coc and lua causes hls to crash.
      coc.settings = {
        "suggest.noselect" = true;
        "suggest.enablePreview" = true;
        "suggest.enablePreselect" = false;
        "suggest.disableKind" = true;
        languageserver = {
          haskell = {
            command = "haskell-language-server-wrapper";
            args = [ "--lsp" ];
            rootPatterns = [
              "*.cabal"
              "stack.yaml"
              "cabal.project"
              "package.yaml"
              "hie.yaml"
            ];
            filetypes = [ "haskell" "lhaskell" ];
          };
        };

      };
      # plugins = with pkgs.vimPlugins; [
      #   vim-nix
      #   coc-tsserver
      #   coc-rust-analyzer
      # ];

      # extraConfig = lib.fileContents ./init.vim;
      extraConfig = ''
        lua << EOF
          ${lib.strings.fileContents ./init.lua}
        EOF
      '';
    };
    tmux = {enable = true; };
  };
  services = {
    # TODO: move ollama from L67 configuration.nix
    # why there or here?
    gnome-keyring.enable = true;
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
    safeeyes.enable = true;
    snixembed = {
      enable = true;

      beforeUnits = [
        # https://github.com/slgobinath/SafeEyes/wiki/How-to-install-backend-for-Safe-Eyes-tray-icon
        "safeeyes.service"
      ];
    };
  };
  home = {
    inherit username homeDirectory;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "21.11";

    packages = defaultPkgs;

    sessionVariables = {
      #DISPLAY = ":0";
      EDITOR = "nvim";
    };
  };
}
