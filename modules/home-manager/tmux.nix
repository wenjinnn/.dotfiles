{
  programs.tmux = {
    enable = true;
    # set it to true will conflict with podman
    secureSocket = false;
  };
  home.file = {
    ".config/tmux" = {
      source = ../../xdg/config/tmux;
      recursive = true;
    };
  };
}
