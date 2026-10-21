{
  config,
  lib,
  hostName,
  ...
}:
let
  baseSettings = builtins.fromJSON (builtins.readFile ./syncthing-settings.json);
  settings = baseSettings // {
    devices = lib.removeAttrs baseSettings.devices [ hostName ];
    folders = lib.mapAttrs (
      _: folder:
      folder
      // {
        devices = lib.filter (device: device != hostName) folder.devices;
      }
    ) baseSettings.folders;
  };
in
{
  sops.secrets.SYNCTHING_GUI_PASSWORD = { };

  services.syncthing = {
    enable = true;
    inherit settings;
    overrideDevices = true;
    overrideFolders = true;
    guiCredentials = {
      username = config.home.username;
      passwordFile = config.sops.secrets.SYNCTHING_GUI_PASSWORD.path;
    };
  };

  systemd.user.services.syncthing = {
    Unit = {
      Requires = [ "sops-nix.service" ];
      After = [ "sops-nix.service" ];
    };
  };
}
