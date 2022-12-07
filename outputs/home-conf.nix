{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.alex = {
    home.packages = with pkgs; [
      neovim
      tmux
      git
      tldr 
      vlc
      xclip #used for ssh on gitlab
      firefox
      brave 
      obsidian
      calibre
      zotero
      #zoom
      discord
      zoom-us
      obs-studio
      pre-commit

      nodejs 
      yarn
      python
      
      # haskell.nix
      # https://jkuokkanen109157944.wordpress.com/2020/11/10/creating-a-haskell-development-environment-with-lsp-on-nixos/
      # ghc
      # cabal2nix
      # cabal-install
      # haskellPackages.haskell-language-server
      # haskellPackages.calligraphy #do I need this? 
      # (neovim.override {
      #   configure = {
      #     packages.myPlugins = with pkgs.vimPlugins; {
      #       start = [ coc-nvim ];
      #       opt = [];
      #     };
      #   };
      #  })
      # #finished
      # blas #hmatrix dependencies
      # lapack #hmatrix dependencies
    ];

    virtualisation.docker.enable = true;
    environment.variables.EDITOR = "nvim";

    # home-manager.useGlobalPkgs = true;
    programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
         GIT_PROMPT_ONLY_IN_REPO=1
         source $HOME/.bash-git-prompt/gitprompt.sh
      fi
    '';
    };
  };
  #nix = {
  #  binaryCaches          = [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
  #  binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo=" ];
  #  package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
  #  extraOptions = ''
  #  	keep-outputs = true
  #    keep-derivations = true
  #    experimental-features = nix-command flakes
  #    '';
  # nix options for derivations to persist garbage collection
  #};
}
