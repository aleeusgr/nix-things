{ inputs, system, ... }:

let
  nixosSystem = inputs.nixpkgs.lib.nixosSystem;
in
{
  m3800 = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../hardware-configuration.nix
      ../configuration.nix
    ];
  };

}
