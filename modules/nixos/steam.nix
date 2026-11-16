{
  pkgs,
  me,
  inputs,
  ...
}:
let
  gs = pkgs.writeShellScript "gs" ''
    set -xeuo pipefail

    /run/wrappers/bin/sudo -n ${pkgs.kmod}/bin/modprobe amdgpu

    hdmiStatus=
    for _ in {1..50}; do
      for status in /sys/class/drm/card*-HDMI-A-4/status; do
        if [[ -r "$status" && "$(<"$status")" == connected ]]; then
          hdmiStatus="$status"
          break 2
        fi
      done
      sleep 0.1
    done
    if [[ -z "$hdmiStatus" ]]; then
      echo "eGPU HDMI-A-4 did not appear; refusing to start Gamescope" >&2
      exit 1
    fi

    if ! /run/wrappers/bin/sudo -n ${pkgs.systemd}/bin/systemctl start game.mount; then
      echo "Failed to mount /game; refusing to start Gamescope" >&2
      exit 1
    fi

    gamescopeArgs=(
        --backend drm
        --prefer-output HDMI-A-4
        --adaptive-sync # VRR support
        --hdr-enabled
        --mangoapp # performance overlay
        --rt
        --steam
        -w 2560
        -h 1440
        -W 2560
        -H 1440
    )
    steamArgs=(
        -pipewire-dmabuf
        -tenfoot
    )
    mangoConfig=(
        cpu_temp
        gpu_temp
        ram
        vram
    )
    mangoVars=(
        MANGOHUD=1
        MANGOHUD_CONFIG="$(IFS=,; echo "''${mangoConfig[*]}")"
    )
    export "''${mangoVars[@]}"
    exec gamescope "''${gamescopeArgs[@]}" -- steam "''${steamArgs[@]}"
  '';
in
{
  imports = [ inputs.aagl.nixosModules.default ];

  nix.settings = inputs.aagl.nixConfig;

  programs = {
    anime-game-launcher.enable = true;
    gamescope = {
      enable = true;
      # Keep disabled: Steam's runtime rejects Gamescope's CAP_SYS_NICE during
      # capability handoff (EPERM); Gamescope still runs, but cannot use --rt.
      # capSysNice = true;
      enableWsi = true;
    };
    steam = {
      # a example for game launch options
      # ENABLE_GAMESCOPE_WSI=1 MANGOHUD=1 DRI_PRIME=0  gamescope -f --hdr-enabled -O HDMI-A-4 -w 2560 -h 1440 -W 3840 -H 2160 -- env DXVK_HDR=1  gamemoderun %command%
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
      protontricks.enable = true;
      extest.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      extraPackages = [ pkgs.gamescope ];
    };
  };
  # hardware.xone.enable = true; # support for the xbox controller USB dongle
  # hardware.xpadneo.enable = true;

  services = {
    # enable scx for game, needs kernel version >= 6.12, see https://github.com/sched-ext/scx/blob/main/scheds/rust/scx_lavd/README.md
    scx-loader = {
      config.default_sched = "scx_lavd";
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      mangohud
      gamemode
    ];
    loginShellInit = ''
      [[ "$(tty)" = "/dev/tty2" ]] && ${gs}
    '';
  };
}
