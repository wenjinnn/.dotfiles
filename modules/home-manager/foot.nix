{ lib, ... }:
{
  # foot
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      scrollback = {
        lines = 10000;
      };
      cursor = {
        color = "1e1e1e cccccc";
      };
      colors = {
        background = "1e1e1e";
        foreground = "cccccc";
        regular0 = "000000";
        regular1 = "cd3131";
        regular2 = "0dbc79";
        regular3 = "e5e510";
        regular4 = "2472c8";
        regular5 = "bc3fbc";
        regular6 = "11a8cd";
        regular7 = "e5e5e5";
        bright0 = "666666";
        bright1 = "f14c4c";
        bright2 = "23d18b";
        bright3 = "f5f543";
        bright4 = "3b8eea";
        bright5 = "d670d6";
        bright6 = "29b8db";
        bright7 = "e5e5e5";
      };
      key-bindings = {
        scrollback-up-page = "Control+Shift+Page_Up";
        scrollback-down-page = "Control+Shift+Page_Down";
        clipboard-copy = "Control+Shift+c";
        clipboard-paste = "Control+Shift+v";
        search-start = "Control+Shift+f";
      };
      search-bindings = {
        cancel = "Escape";
        commit = "Return";
        find-prev = "Control+Shift+p";
        find-next = "Control+Shift+n";
      };
    };
  };
}
