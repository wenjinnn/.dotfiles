{
  pkgs,
  me,
  ...
}:
{

  programs = {
    nautilus-open-any-terminal = {
      enable = true;
      terminal = "foot";
    };
    gtklock = {
      enable = true;
      modules = with pkgs; [
        gtklock-playerctl-module
        gtklock-powerbar-module
        gtklock-userinfo-module
      ];
    };
  };

  security = {
    polkit.enable = true;
  };
  services = {
    gvfs.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    geoclue2.enable = true;
    accounts-daemon.enable = true;
  };
  # tell Electron/Chromium to run on Wayland
  environment.variables.NIXOS_OZONE_WL = "1";
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
        user = me.username;
      };
    };
  };

}
