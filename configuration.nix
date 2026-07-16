# Minimal configuration for OnePlus 6T (fajita) NixOS Mobile
# Focus on essentials: SSH, wireless, and basic tools

{ config, lib, pkgs, ... }:

{
  # Allow unfree packages (needed for OnePlus firmware)
  nixpkgs.config.allowUnfree = true;

  # Enable flakes and the new `nix` CLI (nix run, nix search, etc.)
  # so they work directly from the command line, not just via nixos-rebuild.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable SSH server (essential for mobile device access)
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes"; # For initial setup
  services.openssh.settings.PasswordAuthentication = true; # For initial setup

  # Prepend these DNS servers ahead of whatever NetworkManager/DHCP hands out.
  # Without this, /etc/resolv.conf can end up empty or unresolvable after
  # NetworkManager reconfigures networking on rebuild/reboot.
  networking.networkmanager.insertNameservers = [ "8.8.8.8" "1.1.1.1" ];

  # Let us manage the usb0 (USB gadget) interface manually below,
  # instead of NetworkManager trying to take it over.
  networking.networkmanager.unmanaged = [ "usb0" ];

  # Static IP for the phone's side of the USB link, so it's predictable
  # every time you plug in a computer.
  networking.interfaces.usb0.ipv4.addresses = [
    { address = "172.16.42.1"; prefixLength = 24; }
  ];

  # Run a small DHCP/DNS server on usb0 only, so a connected PC
  # automatically gets an IP in the 172.16.42.0/24 range without any
  # manual `ip addr add` on the PC side.
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = [ "usb0" ];
      bind-interfaces = true;
      except-interface = [ "lo" ];
      dhcp-range = [ "172.16.42.10,172.16.42.50,12h" ];
    };
  };

  # Trust traffic on usb0 (DHCP/DNS requests, SSH, etc.) so the firewall
  # doesn't block the link we just set up above.
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
    extraGroups = [ "wheel" ]; # Needed for sudo access
  };

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
  system.stateVersion = "26.05";
}
