{ inputs, system, ... }:

let
  nixosSystem = inputs.nixpkgs.lib.nixosSystem;
in
{
  dell-prec = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../hardware-configuration.nix
      ../configuration.nix
    ];
  };

}