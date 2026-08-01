# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  egpu-thermal = pkgs.writeShellScript "egpu-thermal" ''
    ACTION=$1

    set_cpu() {
      local max_perf=$1 boost=$2 epp=$3
      for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
        base=$(cat "''${cpu%scaling_max_freq}cpuinfo_max_freq" 2>/dev/null)
        [ -n "$base" ] && echo "$((base * max_perf / 100))" > "$cpu" 2>/dev/null
      done
      for p in /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference; do
        echo "$epp" > "$p" 2>/dev/null
      done
      # no_turbo: 0=turbo ON, 1=turbo OFF
      echo "$boost" > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null
    }

    case "$ACTION" in
      add)
        logger -t egpu-thermal "eGPU connected, lowering CPU to 80%% no-turbo"
        set_cpu 80 1 "balance_performance"
        ;;
      remove)
        logger -t egpu-thermal "eGPU disconnected, restoring CPU to 100%% turbo"
        set_cpu 100 0 "performance"
        ;;
    esac
  '';
in
{
  # You can import other NixOS modules here
  imports = with outputs.nixosModules; [
    # If you want to use modules your own flake exports (from modules/nixos):
    interception-tools
    firewall
    virt
    systemd-boot
    waydroid
    bluetooth
    steam
    de
    fingerprint
    k3s

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  programs.kdeconnect.enable = true;

  nixpkgs.config.rocmSupport = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.ollama = {
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1100"; # used to be necessary, but doesn't seem to anymore
      OLLAMA_KEEP_ALIVE = "30m";
    };
    rocmOverrideGfx = "11.0.1";
  };

  environment.systemPackages = with pkgs; [
    lact
    nvtopPackages.amd
    nvtopPackages.intel
    tpacpi-bat
  ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  powerManagement.powertop.enable = true;
  services = {
    printing.enable = true;
    # flatpak.enable = true;
    thermald.enable = true;
    thinkfan.enable = true;
    power-profiles-daemon.enable = true;
  };

  # Dynamic CPU frequency control when eGPU (RX 7800 XT) is connected via Thunderbolt
  # Prevents thermal shutdown by lowering CPU power when eGPU adds heat
  services.udev.extraRules = ''
    # eGPU (AMD RX 7800 XT) connected via Thunderbolt
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x747e", RUN+="${egpu-thermal} add"
    ACTION=="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x747e", RUN+="${egpu-thermal} remove"
  '';

  services.hardware.bolt.enable = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "uas"
    "sd_mod"
  ];
  boot.kernelModules = [
    "thunderbolt"
    "br_netfilter"
  ];
  boot.kernelParams = [
    "pci=realloc"
    "pci=hpmemsize=1G"
    "pcie_ports=native"
    "amdgpu.gpu_recovery=1"
    "amdgpu.runpm=0"
    "modprobe.blacklist=amdgpu"
  ];

  boot.extraModprobeConfig = ''
    options snd-hda-intel enable=1,0  # only enable the first audio card
    blacklist snd_hda_codec_hdmi  # disable HDMI audio output
  '';

  # Allow wenjin to load amdgpu without password (for user service)
  security.sudo.extraRules = [
    {
      users = [ "wenjin" ];
      commands = [
        {
          command = "${pkgs.kmod}/bin/modprobe amdgpu";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  # User service: loads amdgpu after graphical session starts (i.e. after login)
  systemd.user.services.load-amdgpu = {
    description = "Load amdgpu kernel module for eGPU";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/wrappers/bin/sudo ${pkgs.kmod}/bin/modprobe amdgpu";
      RemainAfterExit = true;
    };
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "com.mitchellh.ghostty.desktop"
      ];
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 75;
    algorithm = "zstd";
    priority = 100;
  };
  # Hibernate fix: de-authorize all Thunderbolt devices before hibernate.
  # This cleanly unloads amdgpu (eGPU) and all other TB devices, preventing
  # the display flash caused by i915 mode set during suspend-to-disk.
  # On resume, re-authorize so devices come back automatically.
  powerManagement.powerDownCommands = ''
    for dev in /sys/bus/thunderbolt/devices/*/authorized; do
      name="$(basename "$(dirname "$dev")")"
      case "$name" in domain*) continue ;; esac
      echo 0 > "$dev" 2>/dev/null
    done
    ${pkgs.udev}/bin/udevadm settle --timeout=10
  '';
  powerManagement.resumeCommands = ''
    for dev in /sys/bus/thunderbolt/devices/*/authorized; do
      name="$(basename "$(dirname "$dev")")"
      case "$name" in domain*) continue ;; esac
      echo 1 > "$dev" 2>/dev/null
    done
    ${pkgs.udev}/bin/udevadm settle --timeout=10

    # After resume, check if eGPU is present and correct CPU state.
    # This handles: hibernate with eGPU → unplug while off → resume without eGPU
    # and: de-authorize didn't trigger udev RUN= during powerDown
    if [ -d /sys/bus/pci/devices/0000:54:00.0 ]; then
      ${egpu-thermal} add
    else
      ${egpu-thermal} remove
    fi
  '';

  networking.hostName = "nixos";
}
