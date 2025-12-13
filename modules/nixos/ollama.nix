{
  pkgs,
  username,
  config,
  lib,
  ...
}
: {
  services = {
    ollama = {
      enable = true;
      home = "/home/ollama";
      user = "ollama";
      group = "ollama";
    };
  };
  users.users = {
    ollama = {
      home = "/home/ollama";
      isSystemUser = true;
      createHome = true;
    };
  };

  # changing ollama home throws error. Follows can fix it, see https://github.com/NixOS/nixpkgs/issues/357604
  systemd.services.ollama.serviceConfig =
    let
      cfg = config.services.ollama;
      ollamaPackage = cfg.package;
    in
    lib.mkForce {
      Type = "exec";
      ExecStart = "${lib.getExe ollamaPackage} serve";
      WorkingDirectory = cfg.home;
      SupplementaryGroups = ["render"];
    };
}
