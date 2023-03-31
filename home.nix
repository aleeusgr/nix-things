{ config, pkgs, ... }:

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
      #ihaskell-blaze 
      #ghcup
    ];
in
  {
    # Let Home Manager install and manage itself:
    programs.home-manager.enable = true;
    programs.autorandr.enable = true; #external monitor
    # programs.obs-studio.enable = true;    
    programs.neovim.enable = true;

    programs.git = {
    enable = true;
    userName  = "Alex";
    userEmail = "alexeusgr@gmail.com";
    };
    # https://github.com/magicmonty/bash-git-prompt 
    programs.bash = {
      enable = true;
      profileExtra = ''
        if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
           GIT_PROMPT_ONLY_IN_REPO=1
           source $HOME/.bash-git-prompt/gitprompt.sh
        fi
      '';
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
