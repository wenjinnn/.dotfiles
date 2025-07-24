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
