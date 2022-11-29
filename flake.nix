{
  description = "plutus-testing";
  nixConfig.bash-prompt = "\\[\\e[0m\\][\\[\\e[0;2m\\]plutus-testing \\[\\e[0;1m\\]plutus-testing \\[\\e[0;93m\\]\\w\\[\\e[0m\\]]\\[\\e[0m\\]$ \\[\\e[0m\\]";

  inputs = {
  #  nixpkgs.follows = "plutip/nixpkgs";
  #  haskell-nix.follows = "plutip/haskell-nix";

  #  plutip.url = "github:mlabs-haskell/plutip";
  };
  outputs = { self, nixpkgs }: {
    # replace 'joes-desktop' with your hostname here.
    nixosConfigurations.alex-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
