{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprlock.homeManagerModules.default
  ];
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
    backgrounds = [
      {
        path = "screenshot";
        blur_passes = 3;
        blur_size = 3;
      }
    ];
    input-fields = [
      {
        size = {
          width = 600;
          height = 100;
        };
        placeholder_text = "";
      }
    ];
    labels = [
      {
        text = "Hi there, $USER";
        font_size = 50;
        font_family = "Sans";
        position = {
          x = 0;
          y = 80;
        };
      }
      {
        text = "$TIME";
        font_size = 150;
        font_family = "Sans";
        position = {
          x = 0;
          y = 600;
        };
      }
    ];
  };
}
