{
  pkgs,
  inputs,
  ...
}:
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
      # ENABLE_GAMESCOPE_WSI=1 MANGOHUD=1 DRI_PRIME=0  gamescope -f --hdr-enabled -O HDMI-A-1 -w 2560 -h 1440 -W 3840 -H 2160 -- env DXVK_HDR=1  gamemoderun %command%
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

  environment.systemPackages = with pkgs; [
    mangohud
    gamemode
  ];
}
