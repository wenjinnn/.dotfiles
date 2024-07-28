{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt"; # must have no password!
    defaultSopsFile = ../../secrets.yaml;
  };

  home.packages = with pkgs; [
    age
    sops
  ];
}
