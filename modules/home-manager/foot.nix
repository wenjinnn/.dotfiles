{pkgs, ...}: {
  # foot
  programs.foot = {
    enable = true;
    package = pkgs.unstable.foot;
    server.enable = true;
    settings = {
      main = {
        font = "monospace:size=12";
        letter-spacing = 0;
        dpi-aware = "no";
        bold-text-in-bright = "no";
      };
      scrollback = {
        lines = 10000;
      };
      # catppuccin foot colorscheme from https://github.com/catppuccin/foot
      colors = {
        foreground = "cdd6f4";
        background = "1e1e2e";

        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";

        bright0 = "585b70";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";

        selection-foreground = "cdd6f4";
        selection-background = "414356";

        search-box-no-match = "11111b f38ba8";
        search-box-match = "cdd6f4 313244";

        jump-labels = "11111b fab387";
        urls = "89b4fa";
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
