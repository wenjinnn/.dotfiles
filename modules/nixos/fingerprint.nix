# NixOS module for fingerprint authentication (fprintd)
# Supports ThinkPad X1 Carbon Gen9 and similar devices
{ config, pkgs, ... }:
{
  # Enable fprintd fingerprint daemon
  services.fprintd = {
    enable = true;
    # tod = {
    #   enable = true;
    #   driver = pkgs.libfprint-2-tod1-vfs0090;  # For Validity sensors
    # };
  };

  # Add fingerprint-related packages
  environment.systemPackages = with pkgs; [
    fprintd
    libfprint
  ];

  # Enable fingerprint authentication for login and sudo
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    # If you use a display manager like SDDM or GDM:
    # sddm.fprintAuth = true;
    # gdm-fingerprint.fprintAuth = true;
  };
}
