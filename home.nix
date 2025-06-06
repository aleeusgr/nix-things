{ config, pkgs, lib, ... }:

let

  username = "alex";
  homeDirectory = "/home/alex";
  defaultPkgs = with pkgs; [

    # UI
    brave
    calibre
    discord
    firefox
    fragments
    kooha #record screen
    obsidian
    slack
    vlc
    zoom-us
    zotero
    mixxx
    element-desktop
    lean4

    # hacky stuff
    # mdbook
    pre-commit
    tldr
    tmux
    xclip
    yt-dlp
    radicle-node

    # dev toolchains
    nodejs
    # nodePackages.pnpm
    python
    gcc
    cargo
    rustc
    rust-analyzer
  ];

  haskellPkgs = with pkgs.haskellPackages; [
    #brittany                # code formatter
    cabal2nix # convert cabal projects to nix
    cabal-install # package manager
    ghc # compiler
    haskell-language-server # haskell IDE (ships with ghcide)
    hoogle # documentation
    nix-tree # visualize nix dependencies
    ihaskell
    haskell-ci
    fourmolu
    #ihaskell-blaze 
    #ghcup
  ];
in
{
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
    gpg = {
      enable = true;
    };
    # Neovim is starting to get huge; should move to a separate file.
    neovim = {
      enable = true;
      coc.enable = true;
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
      plugins = with pkgs.vimPlugins; [
        vim-nix
        coc-tsserver
        coc-rust-analyzer
      ];

      # extraConfig = lib.fileContents ./init.vim;
      extraConfig = ''
        lua << EOF
        ${lib.strings.fileContents ./init.lua}
        EOF
      '';
    };
  };
  services = {
    gnome-keyring.enable = true;
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
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

    packages = defaultPkgs ++ haskellPkgs;

    sessionVariables = {
      #DISPLAY = ":0";
      EDITOR = "nvim";
    };
  };
}
