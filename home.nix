{ config, pkgs, lib, ... }:

let

    username = "alex";
    homeDirectory = "/home/alex";

    defaultPkgs = with pkgs; [ 

    firefox
    tmux
    xclip #used for ssh on gitlab
    brave 
    vlc
    obsidian
    calibre
    zotero
    #zoom
    discord
    zoom-us
    pre-commit
    nodejs 
    yarn
    python
    fragments
    tldr
    youtube-music
    nodePackages.pnpm

    mdbook
    slack

    # for hyperledger/cacti
    docker-compose
    zulu8
    ];

    haskellPkgs = with pkgs.haskellPackages; [
      #brittany                # code formatter
      cabal2nix               # convert cabal projects to nix
      cabal-install           # package manager
      ghc                     # compiler
      haskell-language-server # haskell IDE (ships with ghcide)
      hoogle                  # documentation
      nix-tree                # visualize nix dependencies
      ihaskell
      haskell-ci
      fourmolu
      #ihaskell-blaze 
      #ghcup
    ];
in
  {
    # Let Home Manager install and manage itself:
    programs = {
    home-manager.enable = true;
    # autorandr.enable = true; #external monitor
    # programs.obs-studio.enable = true;    
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
          ];

      extraConfig = lib.fileContents ./init.vim;
      # programs.neovim.extraConfig = ''
      #   set number
      # '';
    };
    git = {
	    enable = true;
	    userName  = "Alex";
	    userEmail = "alexeusgr@gmail.com";
	    };
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
    bash = {
      enable = true;
      profileExtra = ''
        if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
           GIT_PROMPT_ONLY_IN_REPO=1
           source $HOME/.bash-git-prompt/gitprompt.sh
        fi
      '';
      };
    };

    home = {
      inherit username homeDirectory ;

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      stateVersion = "22.11";

      packages = defaultPkgs ++ haskellPkgs ;

      sessionVariables = {
        #DISPLAY = ":0";
        EDITOR = "nvim";
      };
    };

  }
