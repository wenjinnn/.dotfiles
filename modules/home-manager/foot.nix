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
        scrollback-up-page = "Control+Shift+f";
        scrollback-down-page = "Control+Shift+b";
      };
      search-bindings = {
        scrollback-up-page = "Control+Shift+f";
        scrollback-down-page = "Control+Shift+b";
      };
      scrollback = {
        lines = 10000;
      };
    };
  };
}
