{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
      sarasa-gothic
      nerd-fonts.fira-code
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.caskaydia-cove
      font-awesome
      lexend
      material-symbols
      # microsoft fonts
      corefonts
      vistafonts-cht
      vistafonts-chs
      vistafonts
    ];
    fontDir.enable = true;
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = [
          "CaskaydiaCove Nerd Font"
          "Sarasa Mono SC"
        ];
        sansSerif = [
          "Ubuntu Nerd Font"
          "Sarasa UI SC"
        ];
        serif = [
          "Ubuntu Nerd Font"
          "Sarasa fixed Slab SC"
        ];
      };
    };
  };
}
