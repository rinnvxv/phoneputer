# Minimal configuration for OnePlus 6T (fajita) NixOS Mobile
# Focus on essentials: SSH, wireless, and basic tools

{ config, lib, pkgs, ... }:

{
  # Allow unfree packages (needed for OnePlus firmware)
  nixpkgs.config.allowUnfree = true;

  mobile.boot.stage-1.networking.enable = lib.mkDefault true;

  # Enable SSH server (essential for mobile device access)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Set root password for SSH access
  users.users.root.password = "nixtheplanet";

  # Minimal essential packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];
} 
