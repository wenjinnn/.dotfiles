{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [
        pkgs.nautilus-open-any-terminal
      ];
    };
  };
  programs.dconf.enable = true;
  services = {
    sysprof.enable = true;
    gnome = {
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-console
      gnome-text-editor
      gedit
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-contacts
      gnome-initial-setup
      gnome-shell-extensions
    ]);
}
