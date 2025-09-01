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
        scrollback-down-page = "Control+Shift+f";
      };
      search-bindings = {
        scrollback-up-page = "Control+Shift+b";
        scrollback-down-page = "Control+Shift+f";
      };
      scrollback = {
        lines = 10000;
      };
    };
  };
}
