{
  programs.tmux = {
    enable = true;
  };
  home.file = {
    ".config/tmux" = {
      source = ../../xdg/config/tmux;
      recursive = true;
    };
  };
}
