{
  inputs,
  pkgs,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 3;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        }
      ];
      input-field = [
        {
          placeholder_text = "";
        }
      ];
      label = [
        {
          text_align = "right";
          halign = "center";
          valign = "center";
          text = "Hi there, $USER";
          font_size = 50;
          font_family = "Sans";
          position = "0, 80";
        }
        {
          text_align = "right";
          halign = "center";
          valign = "center";
          text = "$TIME";
          font_size = 150;
          font_family = "Sans";
          position = "0, 300";
        }
      ];
    };
  };
}
