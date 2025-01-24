{
  modulesPath,
  outputs,
  config,
  lib,
  pkgs,
  me,
  ...
}: {
  imports = with outputs.nixosModules; [
    (modulesPath + "/virtualisation/amazon-image.nix")
    headscale
  ];

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpMRzF5l2trX2SwRxYn4KcSahIKVbU+T+Li+IE5qMIw wenjin@nixos-wsl"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtBUbTuGD34mJCUZp7hIFuDR9kACg4y8iWhjAPB5R66 wenjin@nixos"
  ];

  system.stateVersion = "24.11";
}
