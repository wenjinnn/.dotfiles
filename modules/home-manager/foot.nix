{ lib, ... }:
{
  # foot
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        selection-target = "both";
      };
      scrollback = {
        lines = 10000;
      };
    };
  };
}
