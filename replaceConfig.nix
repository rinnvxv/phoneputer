# Minimal configuration for OnePlus 6T (fajita) NixOS Mobile
# Focus on essentials: SSH, wireless, and basic tools

{ config, lib, pkgs, ... }:

{ 
  # Allow unfree packages (needed for OnePlus firmware)
  nixpkgs.config.allowUnfree = true;

  # Enable SSH server (essential for mobile device access)
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes"; # For initial setup
  services.openssh.settings.PasswordAuthentication = true; # For initial setup

  # Enable audio
  # PipeWire is enabled by default, but the audio is very quiet with it
  services.pipewire.enable = lib.mkForce false;
  # Make sure to select "Speakers Output" as the output device in the settings
  services.pulseaudio.enable = true;

  # Set root password for SSH access
  users.users.root.password = "0000";

  # fish shell
  # programs.fish.enable = true;

  # Add normal user
  # users.users.user = { # Change user to your username
  #  isNormalUser = true;
  #  initialPassword = "0000"; # Change to your user password
  #  extraGroups = [
  #    "wheel"
  #  ]; # Needed for sudo access
    # shell = pkgs.fish;
  # };

  security.sudo.wheelNeedsPassword = false;

  # Enable GNOME Desktop Environment
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Enable GNOME Keyring for password management
  services.gnome.gnome-keyring.enable = true;

  # Firefox web browser
  programs.firefox.enable = true;

  # Enable dconf for GNOME settings
  programs.dconf.enable = true;

  # Remove unwanted GNOME applications
  environment.gnome.excludePackages = with pkgs; [
    baobab      # disk usage analyzer
    cheese      # photo booth
    eog         # image viewer
    epiphany    # web browser
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer
    evince      # document viewer
    file-roller # archive manager
    geary       # email client
    seahorse    # password manager
    gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts
    gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-screenshot
    gnome-system-monitor gnome-weather gnome-disk-utility pkgs.gnome-connections
  ];

  # Minimal essential packages
  environment.systemPackages = with pkgs; [
    git         # version control
    vim         # text editor
    wget        # file downloader
    curl        # HTTP client
    lazygit     # terminal UI for git
    asciiquarium # just for fun
    neovim      # text editor
    fastfetch   # faster system info display
    kitty.terminfo
  ];

  # noto-fonts for Chinese, Japanese, Korean
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  # This value should match the NixOS release you initially installed with.
  # See: https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.11";
}
