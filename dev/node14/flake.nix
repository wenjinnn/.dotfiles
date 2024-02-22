{
  description = "A Nix-flake-based Node.js development environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }:
    let
      overlays = [
        (final: prev: rec {
          nodejs = prev.nodejs-14_x;
          pnpm = prev.nodePackages.pnpm;
          yarn = (prev.yarn.override { inherit nodejs; });
        })
      ];
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs {
          inherit overlays system;
          config.permittedInsecurePackages = [
            "nodejs-14.21.3"
            "openssl-1.1.1w"
          ];
        };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ node2nix nodejs pnpm yarn ];
          shellHook = ''
            exec zsh
          '';
        };
      });
    };
}
