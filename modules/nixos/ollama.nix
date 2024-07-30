{pkgs, ...}
: {
  services = {
    ollama = {
      package = pkgs.unstable.ollama;
      enable = true;
    };
  };
}
