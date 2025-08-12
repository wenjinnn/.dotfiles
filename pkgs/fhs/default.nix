{
  config,
  pkgs,
  lib,
  ...
}:
# create a fhs environment by command `fhs`, so we can run non-nixos packages in nixos!
let
  base = pkgs.appimageTools.defaultFhsEnvArgs;
in
  pkgs.buildFHSEnv (base
    // {
      name = "fhs";
      targetPkgs = pkgs: (
        # pkgs.appimageTools offered common used pkgs
        (base.targetPkgs pkgs)
        ++ (with pkgs; [
          pkg-config
          ncurses
          # add whether pkgs here
        ])
      );
      profile = "export FHS=1";
      extraOutputsToInstall = ["dev"];
    })
