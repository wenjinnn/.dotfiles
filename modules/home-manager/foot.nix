{ lib, ... }:
{
  # foot
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        selection-target = "both";
      };
      key-bindings = {
        scrollback-up-page = "Control+Shift+b";
        scrollback-up-half-page = "Control+Shift+u";
        scrollback-down-page = "Control+Shift+f";
        scrollback-down-half-page = "Control+Shift+d";
        unicode-input = "Control+Shift+i";
      };
      search-bindings = {
        scrollback-up-page = "Control+Shift+b";
        scrollback-up-half-page = "Control+Shift+u";
        scrollback-down-half-page = "Control+Shift+d";
        scrollback-down-page = "Control+Shift+f";
      };
      scrollback = {
        lines = 10000;
      };
    };
  };
}
