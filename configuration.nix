# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = false;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;
  # boot.supportedFilesystems = [ "ntfs" ];
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";
  time.hardwareClockInLocalTime = false;


  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  # networking.interfaces.wlp6s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services = { 
    xserver = { 
      enable = true;
      videoDrivers = [ "nvidia" ];

      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
  
      # Configure keymap in X11
      layout = "us";
      xkbOptions = "eurosign:e";
      # Enable touchpad support (enabled default in most desktopManager).
      # libinput.enable = true;
    };
    # printing.enable = true; #CUPS
    ollama = {
      enable = true;
      environmentVariables = {
        OLLAMA_ORIGINS="app://obsidian.md*";
      };
    };
    openssh = {
      enable = true;
    };
  };


  virtualisation.docker.enable = true;

  # sound.enable = true;
  # hardware.pulseaudio.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    initialPassword = "pass";
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };
  nixpkgs.config.allowUnfree = true;  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    wget
    jq
    docker-compose
    # direnv
    # nix-direnv
  ];

  environment.variables.EDITOR = "nvim";

  #nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix = {
    # Automate garbage collection
    # gc = {
    #   automatic = true;
    #   dates     = "weekly";
    #   options   = "--delete-older-than 7d";
    # };

    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;

      experimental-features = ["nix-command" "flakes"];
      
      substituters = [
      "https://cache.nixos.org/"
      "https://cache.iog.io"
      # "https://cache.zw3rk.com"
      ];
      trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      # "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      ];
    };
  };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  nixpkgs.config.permittedInsecurePackages = [
                "python-2.7.18.8"
              ];
}
