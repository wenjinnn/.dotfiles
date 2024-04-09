{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    package = pkgs.unstable.yazi;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        show_symlink = true;
      };
      preview = {
        max_width = 1500;
        max_height = 1500;
      };
    };
    theme = {
      manager = {
        border_symbol = " ";
      };
      status = {
        separator_open = "";
        separator_close = "";
      };
    };
  };
}
