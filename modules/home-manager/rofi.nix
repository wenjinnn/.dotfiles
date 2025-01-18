{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    rofi-power-menu
    rofi-bluetooth
    rofi-pulse-select
    rofi-systemd
    rofi-network-manager
    rofi-screenshot-wayland
    rofimoji
    cava
  ];
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    pass = {
      enable = true;
      package = pkgs.rofi-pass-wayland;
      extraConfig = ''
        edit_terminal_command=foot
      '';
    };
    terminal = "${pkgs.foot}/bin/foot";
    extraConfig = {
      modes = "drun,run,window,ssh,calc,keys,recursivebrowser";
      show-icons = true;
    };
    plugins = [pkgs.rofi-calc];
    theme = let
      # Use `mkLiteral` for string-like values that should show without
      # quotes, e.g.:
      # {
      #   foo = "abc"; => foo: "abc";
      #   bar = mkLiteral "abc"; => bar: abc;
      # };
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "#mainbox" = {
        children = map mkLiteral ["inputbar" "message" "listview" "mode-switcher"];
      };
      "#window" = {
        border = 1;
      };
      "#inputbar" = {
        children = map mkLiteral ["prompt" "textbox-prompt-colon" "entry" "num-filtered-rows" "textbox-num-sep" "num-rows" "case-indicator"];
      };
      "#textbox-prompt-colon" = {
        expand = false;
        str = "";
        margin = mkLiteral "0px 0.3em 0em 0em";
        text-color = mkLiteral "@foreground-color";
      };
      "#entry" = {
        text-color = mkLiteral "inherit";
        placeholder-color = mkLiteral "var(lightbg)";
      };
      "#num-filtered-rows" = {
        expand = false;
        text-color = mkLiteral "inherit";
      };
      "#num-rows" = {
        expand = false;
        text-color = mkLiteral "inherit";
      };
      "#textbox-num-sep" = {
        expand = false;
        str = "/";
        text-color = mkLiteral "inherit";
      };
      "#case-indicator" = {
        spacing = 0;
        text-color = mkLiteral "inherit";
      };
    };
  };
}
