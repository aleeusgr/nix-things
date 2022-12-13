{ inputs, system, ... }:

with inputs;

let

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
      #neovim-flake.overlays.default
      (import ../home/overlays/protonvpn-gui)
    ];
  };


  imports = [
    homeage.homeManagerModules.homeage
    #neovim-flake.nixosModules.hm
    ../home.nix
  ];

  mkHome = { hidpi ? false }: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      extraSpecialArgs = {
        inherit hidpi inputs;
      };

      modules = [{ inherit imports; }];
    }
  );
in
{
  m3800-edp = mkHome { hidpi = false; };
  m3800-hdmi = mkHome { hidpi = true; };

}
