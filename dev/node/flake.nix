{
  description = "A Nix-flake-based Node.js development environment";

  inputs.nixpkgs.url = "https://github.com/nixos/nixpkgs/.*.tar.gz";

  outputs = {
    self,
    nixpkgs,
  }: let
    overlays = [
      (final: prev: rec {
        nodejs = prev.nodejs-18_x;
        pnpm = prev.nodePackages.pnpm;
        yarn = prev.yarn.override {inherit nodejs;};
      })
    ];
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit overlays system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [libgcc node2nix nodejs pnpm yarn];
        shellHook = ''
          export NODE_OPTIONS=--openssl-legacy-provider
          exec zsh
        '';
      };
    });
  };
}
