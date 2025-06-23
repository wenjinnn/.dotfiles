{ pkgs, ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        mouse_left_click = "context, close_current";
        # TODO maybe change rofi title
        dmenu = "${pkgs.rofi-wayland}/bin/rofi -dmenu -p action";
      };
      ignore_kde_connect = {
        appname = "KDE Connect";
        summary = "System UI";
        skip_display = true;
      };
    };
  };
}
