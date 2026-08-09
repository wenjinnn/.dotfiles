# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, ... }:
{
  # example = pkgs.callPackage ./example { };
  wallpaper-get = pkgs.callPackage ./wallpaper-get { };
  wallpaper-switch = pkgs.callPackage ./wallpaper-switch { };
  fhs = pkgs.callPackage ./fhs { };
  rofi-screenshot-wayland = pkgs.callPackage ./rofi-screenshot-wayland { };
  oh-my-pi = pkgs.callPackage ./oh-my-pi/package.nix { };
  pi-acp = pkgs.callPackage ./pi-acp/package.nix { };
  pi-web = pkgs.callPackage ./pi-web/package.nix { };
  # jdtls wrapper for pi-lens: no metadata files at project root + shared nvim cache dirs
  jdtls-pi-lens = pkgs.callPackage ./jdtls-pi-lens { };
}
