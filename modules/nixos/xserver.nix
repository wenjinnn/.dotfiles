{pkgs, ...}: {
  services.xserver = {
    displayManager.startx.enable = true;
    enable = true;
    # dpi = 192;
    # xkb.layout = "us";
    excludePackages = [pkgs.xterm];
    # libinput.enable = true;
  };
}
