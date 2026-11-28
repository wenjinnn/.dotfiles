{ pkgs, lib, ... }:
let
  eePresets = pkgs.fetchFromGitHub {
    owner = "JackHack96";
    repo = "EasyEffects-Presets";
    rev = "1ac92c9be57bdfccec3fb9820924f9a870a9d56f";
    hash = "sha256-Nd4LOgiZyrrkXeWfpBfrEkZwJ+i/xVjg6EPNf/+sGjw=";
  };
  presetFiles = builtins.readDir "${eePresets}";
  jsonPresets = lib.filterAttrs (
    name: type: type == "regular" && lib.hasSuffix ".json" name
  ) presetFiles;
  irsFiles = builtins.readDir "${eePresets}/irs";
in
{
  services.easyeffects.enable = true;

  xdg.configFile = builtins.listToAttrs (
    (map (name: {
      name = "easyeffects/output/${name}";
      value.source = "${eePresets}/${name}";
    }) (lib.attrNames jsonPresets))
    ++ (map (name: {
      name = "easyeffects/irs/${name}";
      value.source = "${eePresets}/irs/${name}";
    }) (lib.attrNames irsFiles))
  );
}
