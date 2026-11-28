{
  inputs,
  lib,
  modulesPath,
  outputs,
  pkgs,
  ...
}:
let
  steamLauncher = pkgs.writeShellScript "minidesk-steam" ''
    set -o pipefail
    ${pkgs.gamescope}/bin/gamescope \
      --hdr-enabled -O HDMI-A-1 --mangoapp --rt --steam \
      -- steam -pipewire-dmabuf -tenfoot 2>&1 | ${pkgs.systemd}/bin/systemd-cat --identifier=minidesk-gamescope
  '';
in
{
  imports = [
    inputs.aagl.nixosModules.default
    (modulesPath + "/installer/scan/not-detected.nix")
  ]
  ++ (with outputs.nixosModules; [
    bluetooth
    firewall
    systemd-boot
    (k3s {
      serverAddr = "https://nixos.ts.wenjin.me:6443";
    })
  ]);

  nix.settings = inputs.aagl.nixConfig;

  networking.hostName = "nixos-minidesk";
  networking.networkmanager.enable = true;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "uas"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.loader.efi.canTouchEfiVariables = true;

  # Launch the Steam session directly on the connected discrete-GPU HDMI output.
  systemd.services.greetd = {
    after = [ "mihomo.service" ];
    wants = [ "mihomo.service" ];
  };

  services.greetd = {
    enable = true;
    settings = {
      terminal.vt = 1;
      default_session = {
        command = "${steamLauncher}";
        user = "wenjin";
      };
    };
  };

  programs = {
    anime-game-launcher.enable = true;
    gamescope = {
      enable = true;
      enableWsi = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      extraPackages = [ pkgs.gamescope ];
    };
  };

  services.scx-loader = {
    enable = true;
    config.default_sched = "scx_lavd";
  };

  environment.systemPackages = with pkgs; [
    gamemode
    mangohud
    rsync
    bluetui
  ];

  # Match the nixos host: use QEMU user-mode emulation to build AArch64 packages for RPi5.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  security.sudo.wheelNeedsPassword = false;

  systemd.services.k3s.serviceConfig.CPUWeight = 20;

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
    priority = 100;
  };

  # Keep background services from the shared workstation profile off this gaming host.
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.docker.rootless.enable = lib.mkForce false;
  services.ollama.enable = lib.mkForce false;
}
