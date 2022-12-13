{ config, lib, pkgs, stdenv, inputs, ... }:

let
  username = "alex";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  # workaround to open a URL in a new tab in the specific firefox profile
  # work-browser = pkgs.callPackage ./programs/browsers/work.nix {};

  defaultPkgs = with pkgs; [
    audacious            # simple music player
    bottom               # alternative to htop & ytop
    cachix               # nix caching
    calibre              # e-book reader
    discord              # my chat of choice
    dconf2nix            # dconf (gnome) files to nix converter
    #dmenu                # application launcher
    #docker-compose       # docker manager
    #dive                 # explore docker layers
    #drawio               # diagram design
    #duf                  # disk usage/free utility
    #exa                  # a better `ls`
    #fd                   # "find" for files
    #gimp                 # gnu image manipulation program
    #glow                 # terminal markdown viewer
    #gnomecast            # chromecast local files
    #hyperfine            # command-line benchmarking tool
    #insomnia             # rest client with graphql support
    #jmtpfs               # mount mtp devices
    #killall              # kill processes by name
    #kodi                 # media player  
    #krita                # image editor (supposedly better than gimp)
    #libreoffice          # office suite
    #libnotify            # notify-send command4
    #mkvtoolnix           # tools for encoding MKV files, etc
    #betterlockscreen      # fast lockscreen based on i3lock
    #ncdu                 # disk space info (a better du)
    nfs-utils            # utilities for NFS
    #ngrok                # secure tunneling to localhost
    #nix-index            # locate packages containing certain nixpkgs
    #mr                   # mass github actions
    #md-toc               # generate ToC in markdown files
    #mpv                  # media player
    #pavucontrol          # pulseaudio volume control
    #paprefs              # pulseaudio preferences
    #pasystray            # pulseaudio systray
    #pgcli                # modern postgres client
    #playerctl            # music player controller
    #prettyping           # a nicer ping
    #protonvpn-gui        # official proton vpn client
    #pulsemixer           # pulseaudio mixer
    #ranger               # terminal file explorer
    #rawtherapee          # raw photo manipulation and grading
    #ripgrep              # fast grep
    #rnix-lsp             # nix lsp server
    #simple-scan          # scanner gui
    #simplescreenrecorder # screen recorder gui
    #slack                # messaging client
    #tdesktop             # telegram messaging client
    #tex2nix              # texlive expressions for documents
    tldr                 # summary of a man page
    #tree                 # display files in a tree view
    vlc                  # media player
    #xsel                 # clipboard support (also for neovim)
    #yad                  # yet another dialog - fork of zenity
    #xssproxy             # suspends screensaver when watching a video (forward org.freedesktop.ScreenSaver calls to Xss)
    #xautolock
    #hue-cli
    #element

    # work stuff
    # work-browser

    # FOSS additions
    # ungoogled-chromium
    obsidian


    #  Security
    rage                     # encryption tool for secrets management
    keepassxc                # Security ##
    gnupg                    # Security ##
    #ledger-live-desktop      # Ledger Nano X Support for NixOS
    bitwarden-cli            # command-line client for the password manager

    
    binutils-unwrapped       # fixes the `ar` error required by cabal
    jupyter
  ];

  gnomePkgs = with pkgs.gnome; [
    eog            # image viewer
    evince         # pdf reader
    nautilus       # file manager
    gucharmap      # gnome character map (for font creation) 
  ];

  #haskellPkgs = with pkgs.haskellPackages; [
  #  brittany                # code formatter
  #  cabal2nix               # convert cabal projects to nix
  #  cabal-install           # package manager
  #  ghc                     # compiler
  #  haskell-language-server # haskell IDE (ships with ghcide)
  #  hoogle                  # documentation
  #  nix-tree                # visualize nix dependencies
  #  ihaskell
  #  ihaskell-blaze 
  #  #ghcup
  #];

  #cardanoNodePkgs = with inputs.cardano-node.packages.x86_64-linux; [
  #  cardano-node
  #  cardano-cli
  #];

/*
  plutusPkgs = with inputs.plutus.packages.${system}; [
    plutus_repl
    #plutus_cli
  ]; 
  plutusAppsPkgs = with inputs.plutus-apps.packages.${system}; [
    plutus-pab-executables.components.exes.pab-cli
    plutus-chain-index.components.exes.plutus-chain-index
    marconi.components.exes.marconi
    marconi-mamba.components.exes.marconi-mamba
    plutus-example.components.exes.create-script-context
  ];  
*/

in

{
  programs.home-manager.enable = true;

    imports = builtins.concatMap import [
    #./modules
    #./programs
    #./scripts
    #./services
    #./themes
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory;
    stateVersion = "22.11";

    packages = defaultPkgs ++ gnomePkgs ++ cardanoNodePkgs ++ haskellPkgs;

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
    };
    #pointerCursor = { 
    #  name = "phinger-cursors"; 
    #  package = pkgs.phinger-cursors; 
    #  size = 25; 
    #  gtk.enable = true; 
    #};
  };
  
  # restart services on change
  systemd.user.startServices = "sd-switch";

  xsession.numlock.enable = true;
  
  # notifications about home-manager news
  news.display = "silent";
}
