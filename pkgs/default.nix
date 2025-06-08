# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  # example = pkgs.callPackage ./example { };
  bingwallpaper-get = pkgs.callPackage ./bingwallpaper-get {};
  wallpaper-switch = pkgs.callPackage ./wallpaper-switch {};
  fhs = pkgs.callPackage ./fhs {};
  rofi-screenshot-wayland = pkgs.callPackage ./rofi-screenshot-wayland {};
  gh-models = pkgs.callPackage ./gh-models {};
}
