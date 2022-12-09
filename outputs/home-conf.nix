{ config, pkgs, ... }:
#let
#  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
#in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager.users.alex = {
    home.packages = with pkgs; [
      tldr 
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
