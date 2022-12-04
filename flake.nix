{
  description = "Home Manager (dotfiles) and NixOS configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    #nurpkgs = {
    #  url = github:nix-community/NUR;
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #tex2nix = {
    #  url = github:Mic92/tex2nix/4b17bc0;
    #  inputs.utils.follows = "nixpkgs";
    #};
  };

  #outputs = inputs @ { self, nixpkgs, nurpkgs, home-manager, tex2nix }:
  outputs = inputs @ { self, nixpkgs, home-manager, }:
    let
      system = "x86_64-linux";
    in
    {
      homeConfigurations = (
        import ./outputs/home-conf.nix {
          #inherit system nixpkgs nurpkgs home-manager tex2nix;
          inherit system nixpkgs home-manager ;
        }
      );

      nixosConfigurations = (
        import ./outputs/nixos-conf.nix {
          inherit (nixpkgs) lib;
          inherit inputs system;
        }
      );

    };
}
