{
 description = "my-system";
 #nixConfig.bash-prompt = "\\[\\e[0m\\][\\[\\e[0;2m\\]plutus-testing \\[\\e[0;1m\\]plutus-testing \\[\\e[0;93m\\]\\w\\[\\e[0m\\]]\\[\\e[0m\\]$ \\[\\e[0m\\]";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cardano-node.url = "github:input-output-hk/cardano-node";

    #nurpkgs.url = github:nix-community/NUR;

    #homeage = {
    #  url = github:jordanisaacs/homeage;
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #neovim-flake = {
    #  url = github:gvolpe/neovim-flake;
    #  # neovim-flake pushes its binaries to the cache using its own nixpkgs version
    #  # if we instead use ours, we'd be rebuilding all plugins from scratch
    #  #inputs.nixpkgs.follows = "nixpkgs";
    #};

  };
  outputs = { self, nixpkgs, home-manager, cardano-node}: {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules =
        [ ({ pkgs, ... }: {

            # Let 'nixos-version --json' know about the Git revision of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

            environment.systemPackages = [cardano-node.packages.x86_64-linux.cardano-node];
          })
          
          ./configuration.nix
        ];
    };

  };
}
