{
  description = "NixOS configuration";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };


  outputs = inputs @ { self, nixpkgs, home-manager }:
    let system = "x86_64-linux"; in {

      homeConfigurations = (
        import ./home-conf.nix {
          inherit inputs system;
        }
      );
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
          ];
        };
      };
    };
}
