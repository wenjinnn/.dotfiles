{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      preview = {
        max_width = 1500;
        max_height = 1500;
      };
    };
    theme = {
      mgr = {
        show_hidden = true;
        show_symlink = true;
        linemode = "mtime";
        border_symbol = " ";
      };
      status = {
        separator_open = "";
        separator_close = "";
        sep_left = {
          open = "";
          close = "";
        };
        sep_right = {
          open = "";
          close = "";
        };
      };
    };
  };
}
