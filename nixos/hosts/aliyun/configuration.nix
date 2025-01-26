{
  modulesPath,
  config,
  lib,
  outputs,
  pkgs,
  me,
  ...
}: {
  imports = with outputs.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    (headscale {
      inherit config me;
      domain = "wenjin.me";
    })
    rustdesk-server
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services = {
    openssh.enable = true;
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpMRzF5l2trX2SwRxYn4KcSahIKVbU+T+Li+IE5qMIw wenjin@nixos-wsl"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtBUbTuGD34mJCUZp7hIFuDR9kACg4y8iWhjAPB5R66 wenjin@nixos"
  ];

  system.stateVersion = "24.11";
}
