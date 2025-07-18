{
  pkgs,
  me,
  ...
}: let
  gs = pkgs.writeShellScript "gs" ''
    set -xeuo pipefail

    gamescopeArgs=(
        --adaptive-sync # VRR support
        --hdr-enabled
        --mangoapp # performance overlay
        --rt
        --steam
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
in {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
      extest.enable = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
      extraPackages = with pkgs; [gamescope];
    };
  };
  hardware.xone.enable = true; # support for the xbox controller USB dongle
  hardware.xpadneo.enable = true;

  services = {
    # enable scx for game, needs kernel version >= 6.12, see https://github.com/sched-ext/scx/blob/main/scheds/rust/scx_lavd/README.md
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };
  security.sudo.extraConfig = ''
    ${me.username} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/tee /sys/devices/system/cpu/intel_pstate/no_turbo
  '';

  environment = {
    systemPackages = with pkgs; [
      mangohud
      gamemode
    ];
    # disable intel cpu turbo while gaming
    etc."gamemode.ini".text = ''
      [custom]
      start=echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
      end=echo "0" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
    '';
    loginShellInit = ''
      [[ "$(tty)" = "/dev/tty2" ]] && ${gs}
    '';
  };
}
