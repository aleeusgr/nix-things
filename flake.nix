{
 description = "my-system";
 nixConfig.bash-prompt = "\\[\\e[0m\\][\\[\\e[0;2m\\]plutus-testing \\[\\e[0;1m\\]plutus-testing \\[\\e[0;93m\\]\\w\\
[\\e[0m\\]]\\[\\e[0m\\]$ \\[\\e[0m\\]";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";

  outputs = { self, nixpkgs }: {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [ ({ pkgs, ... }: {

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

            # Network configuration.
            # networking.useDHCP = false;
            # networking.firewall.allowedTCPPorts = [ 80 ];

            # Enable a web server.
            # services.httpd = {
            #  enable = true;
            #  adminAddr = "morty@example.org";
            #};
          })
          ./configuration.nix
        ];
    };

  };
}
