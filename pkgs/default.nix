# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...} : {
  # example = pkgs.callPackage ./example { };
  bingwallpaper-get = pkgs.callPackage ./bingwallpaper-get { };
  swww-switch = pkgs.callPackage ./swww-switch { };
  fhs = pkgs.callPackage ./fhs { };
}
