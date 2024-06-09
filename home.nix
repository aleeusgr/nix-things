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
      discord
      zoom-us
      pre-commit
      nodejs 
      yarn
      python
      fragments
      tldr
      nodePackages.pnpm
      mdbook
      slack
      kooha
      llm-ls
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
    askaiScript = pkgs.runCommand "askai" { } ''
      mkdir -p $out/bin
      cp ${./askai.sh} $out/bin/askai
      chmod +x $out/bin/askai
    '';
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
              userName  = "Alex";
              userEmail = "alexeusgr@gmail.com";
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
              llm-nvim
            ];

        # extraConfig = lib.fileContents ./init.vim;
        extraConfig = ''
          lua << EOF
          ${lib.strings.fileContents ./init.lua}
          EOF
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
      stateVersion = "21.11";

      packages = defaultPkgs ++ haskellPkgs  ++ [ askaiScript ] ;
      
      shellAliases = {
        askai = "askai";
      };

      sessionVariables = {
        #DISPLAY = ":0";
        EDITOR = "nvim";
      };
    };
}
