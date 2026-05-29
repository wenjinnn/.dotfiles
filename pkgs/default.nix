# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  # example = pkgs.callPackage ./example { };
  bingwallpaper-get = pkgs.callPackage ./bingwallpaper-get {};
  wallpaper-switch = pkgs.callPackage ./wallpaper-switch {};
  fhs = pkgs.callPackage ./fhs {};
  rofi-screenshot-wayland = pkgs.callPackage ./rofi-screenshot-wayland {};
  pi-acp = pkgs.callPackage ./pi-acp {};

  # Pi packages - uses buildNpmPackage for packages with dependencies
  piPackages = import ./pi-packages {
    inherit pkgs;
    lib = pkgs.lib;
  };
}
