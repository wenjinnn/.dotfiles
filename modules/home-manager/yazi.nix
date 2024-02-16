{
  programs.yazi = {
    enable = true;
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
  };

}
