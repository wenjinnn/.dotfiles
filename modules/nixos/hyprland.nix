{
  config,
  pkgs,
  username,
  ...
}: {
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
    ];
  };
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
    pam.services.ags = {};
  };
  services = {
    gvfs.enable = true;
    devmon.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    accounts-daemon.enable = true;
  };
  
}
