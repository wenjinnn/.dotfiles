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
      source-han-serif-vf-ttf
      source-han-serif-vf-otf
      source-han-serif
      source-han-sans-vf-ttf
      source-han-sans-vf-otf
      source-han-sans
      source-han-mono
      source-han-code-jp
      font-awesome
      lexend
      material-symbols
      wqy_zenhei
      wqy_microhei
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
