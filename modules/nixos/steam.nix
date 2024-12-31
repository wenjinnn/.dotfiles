{
  pkgs,
  username,
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
    };
  };
  hardware.xone.enable = true; # support for the xbox controller USB dongle
  hardware.xpadneo.enable = true;
  services.getty.autologinUser = username;
  environment = {
    systemPackages = [pkgs.mangohud];
    loginShellInit = ''
      [[ "$(tty)" = "/dev/tty2" ]] && ${gs}
    '';
  };
}
