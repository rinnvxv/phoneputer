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

  networking.networkmanager.unmanaged = [ "usb0" ];

  networking.interfaces.usb0.ipv4.addresses = [
    { address = "172.16.42.1"; prefixLength = 24; }
  ];

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = [ "usb0" ];
      bind-interfaces = true;
      except-interface = [ "lo" ];
      dhcp-range = [ "172.16.42.10,172.16.42.50,12h" ];
    };
  };

  networking.firewall.trustedInterfaces = [ "usb0" ];

  # Enable audio
  # PipeWire is enabled by default, but the audio is very quiet with it
  services.pipewire.enable = lib.mkForce false;
  # Make sure to select "Speakers Output" as the output device in the settings
  services.pulseaudio.enable = true;

  # Set root password for SSH access
  users.users.root.password = "nixtheplanet"; # Change to your root password

  # Add normal user
  users.users.user = { # Change user to your username
    isNormalUser = true;
    initialPassword = "nixtheplanet"; # Change to your user password
    extraGroups = [ "wheel" ];
  };

  # Enable GNOME Desktop Environment
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Enable GNOME Keyring for password management
  services.gnome.gnome-keyring.enable = true;

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
    git
    vim
    wget
    curl
    lazygit
    asciiquarium
    neovim
    neofetch
    fastfetch
  ];

  system.stateVersion = "26.05";
}
