{
  inputs,
  outputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  gtklock-powerbar = "${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so";
  gtklock-userinfo = "${pkgs.gtklock-userinfo-module}/lib/gtklock/userinfo-module.so";
  gtklock-playerctl = "${pkgs.gtklock-playerctl-module}/lib/gtklock/playerctl-module.so";
  gtklock = "${lib.getExe pkgs.gtklock} -m ${gtklock-powerbar} -m ${gtklock-userinfo} -m ${gtklock-playerctl}";
in
{

  imports = with outputs.homeManagerModules; [
    inputs.niri.homeModules.niri
    de-basic
    waybar-vertical
    rofi
    dunst
    udiskie
    cliphist
    kdeconnect
    wallpaper
  ];
  xdg.configFile."autostart/nm-applet.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Network Manager Applet
    Exec=nm-applet
    Hidden=true
  '';

  services = {
    network-manager-applet.enable = false;
    gammastep = {
      enable = true;
      dawnTime = "6:00-7:45";
      duskTime = "18:35-20:15";
      provider = "geoclue2";
      tray = true;
    };
    swayidle =
      let
        niri = lib.getExe pkgs.niri-unstable;
      in
      {
        enable = true;
        extraArgs = [
          "-w"
        ];
        events = [
          {
            event = "lock";
            command = "${gtklock} -d";
          }
          {
            event = "before-sleep";
            command = "${gtklock} -d && sleep 1 && ${niri} msg action power-off-monitors";
          }
          {
            event = "after-resume";
            command = "${niri} msg action power-on-monitors";
          }
        ];
        timeouts = [
          {
            timeout = 300;
            command = "${gtklock} -d";
          }
          {
            timeout = 360;
            command = "${niri} msg action power-off-monitors";
          }
        ];
      };
  };
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings =
      let
        colors = config.lib.stylix.colors.withHashtag;
      in
      {
        input = {
          keyboard.numlock = true;
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
        };
        prefer-no-csd = true;
        xwayland-satellite = {
          enable = true;
          path = lib.getExe pkgs.xwayland-satellite-unstable;
        };
        layout = {
          gaps = 12;
          center-focused-column = "never";
          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          default-column-width = {
            proportion = 0.5;
          };
          focus-ring = {
            active.gradient = {
              from = colors.base0D;
              to = colors.base08;
              angle = 45;
            };
            width = 2;
          };
          shadow.enable = true;
          struts = {
            top = -3;
            bottom = -3;
            left = 6;
            right = 6;
          };
        };
        screenshot-path = "~/Pictures/Screenshots/Screenshot-%Y-%m-%d %H-%M-%S.png";
        spawn-at-startup = [
          {
            command = [
              # xrdb dpi scale for xwayland-satellite in 4k screen
              "bash"
              "-c"
              "echo 'Xft.dpi: 192' | xrdb -merge"
            ];
          }
        ];
        binds =
          with config.lib.niri.actions;
          let
            sh = spawn "sh" "-c";
            rofi-cliphist = "rofi -modi clipboard:${pkgs.cliphist}/bin/cliphist-rofi-img -show clipboard -show-icons";
          in
          {
            "Mod+Return" = {
              hotkey-overlay = {
                title = "Open a Terminal: foot (client)";
              };
              action = spawn "footclient";
            };
            "Mod+Shift+Slash".action = show-hotkey-overlay;
            "Mod+D" = {
              hotkey-overlay = {
                title = "Run an Application: rofi";
              };
              action = sh "rofi -show drun";
            };
            "Mod+V" = {
              hotkey-overlay = {
                title = "List clipboard history: rofi-cliphist";
              };
              action = sh rofi-cliphist;
            };
            "Super+Alt+L" = {
              hotkey-overlay = {
                title = "Lock the Screen: gtklock";
              };
              action = sh "${gtklock}";
            };

            "XF86AudioRaiseVolume" = {
              allow-when-locked = true;
              action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
            };
            "XF86AudioLowerVolume" = {
              allow-when-locked = true;
              action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
            };
            "XF86AudioMute" = {
              allow-when-locked = true;
              action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            };

            "Mod+O" = {
              repeat = false;
              action = toggle-overview;
            };

            "Mod+Ctrl+P" = {
              hotkey-overlay.title = "Pause player: playerctl play-pause";
              action = sh "playerctl play-pause";
            };
            "Mod+Shift+P" = {
              hotkey-overlay.title = "Previous player: playerctl previous";
              action = sh "playerctl previous";
            };
            "Mod+Shift+N" = {
              hotkey-overlay.title = "Next player: playerctl next";
              action = sh "playerctl next";
            };
            "Mod+S" = {
              hotkey-overlay.title = "Systemd unit menu: rofi-systemd";
              action = sh "rofi-systemd";
            };
            "Mod+B" = {
              hotkey-overlay.title = "Bluetooth menu: rofi-bluetooth";
              action = sh "rofi-bluetooth";
            };
            "Mod+Alt+P" = {
              hotkey-overlay.title = "Pick color to clipboard: niri msg pick-color";
              action = sh "niri msg pick-color | grep -o '#[0-9a-fA-F]\{6\}' | wl-copy";
            };
            "Mod+P" = {
              hotkey-overlay.title = "Pass menu: rofi-pass";
              action = sh "rofi-pass";
            };
            "Mod+A" = {
              hotkey-overlay = {
                title = "Trigger notification actions: dunstctl context";
              };
              action = sh "dunstctl context";
            };
            "Mod+Ctrl+A" = {
              hotkey-overlay.title = "Pulseaudio sink menu: rofi-pulse-select sink";
              action = sh "rofi-pulse-select sink";
            };
            "Mod+Shift+A" = {
              hotkey-overlay.title = "Pulseaudio source menu: rofi-pulse-select source";
              action = sh "rofi-pulse-select source";
            };
            "Mod+E" = {
              hotkey-overlay.title = "Emoji menu: rofimoji";
              action = sh "rofimoji";
            };
            "Mod+N" = {
              hotkey-overlay.title = "Network menu: rofi-network-manager";
              action = sh "rofi-network-manager";
            };
            "Mod+Ctrl+Shift+P" = {
              hotkey-overlay.title = "Power menu: rofi-power-menu";
              action = sh "rofi -show power-menu -modi power-menu:rofi-power-menu";
            };

            "Mod+Q".action = close-window;

            "Mod+Left".action = focus-column-left;
            "Mod+Down".action = focus-window-down;
            "Mod+Up".action = focus-window-up;
            "Mod+Right".action = focus-column-right;
            "Mod+H".action = focus-column-left;
            "Mod+J".action = focus-window-down;
            "Mod+K".action = focus-window-up;
            "Mod+L".action = focus-column-right;

            "Mod+Ctrl+Left".action = move-column-left;
            "Mod+Ctrl+Down".action = move-window-down;
            "Mod+Ctrl+Up".action = move-window-up;
            "Mod+Ctrl+Right".action = move-column-right;
            "Mod+Ctrl+H".action = move-column-left;
            "Mod+Ctrl+J".action = move-window-down;
            "Mod+Ctrl+K".action = move-window-up;
            "Mod+Ctrl+L".action = move-column-right;

            "Mod+Home".action = focus-column-first;
            "Mod+End".action = focus-column-last;
            "Mod+Ctrl+Home".action = move-column-to-first;
            "Mod+Ctrl+End".action = move-column-to-last;

            "Mod+Shift+Left".action = focus-monitor-left;
            "Mod+Shift+Down".action = focus-monitor-down;
            "Mod+Shift+Up".action = focus-monitor-up;
            "Mod+Shift+Right".action = focus-monitor-right;
            "Mod+Shift+H".action = focus-monitor-left;
            "Mod+Shift+J".action = focus-monitor-down;
            "Mod+Shift+K".action = focus-monitor-up;
            "Mod+Shift+L".action = focus-monitor-right;

            "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
            "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
            "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
            "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
            "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
            "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
            "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
            "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

            "Mod+Page_Down".action = focus-workspace-down;
            "Mod+Page_Up".action = focus-workspace-up;
            "Mod+U".action = focus-workspace-up;
            "Mod+I".action = focus-workspace-down;
            "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
            "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
            "Mod+Ctrl+U".action = move-column-to-workspace-down;
            "Mod+Ctrl+I".action = move-column-to-workspace-up;

            "Mod+Shift+Page_Down".action = move-workspace-down;
            "Mod+Shift+Page_Up".action = move-workspace-up;
            "Mod+Shift+U".action = move-workspace-down;
            "Mod+Shift+I".action = move-workspace-up;

            "Mod+WheelScrollDown" = {
              cooldown-ms = 150;
              action = focus-workspace-down;
            };
            "Mod+WheelScrollUp" = {
              cooldown-ms = 150;
              action = focus-workspace-up;
            };
            "Mod+Ctrl+WheelScrollDown" = {
              cooldown-ms = 150;
              action = move-column-to-workspace-down;
            };
            "Mod+Ctrl+WheelScrollUp" = {
              cooldown-ms = 150;
              action = move-column-to-workspace-up;
            };

            "Mod+WheelScrollRight".action = focus-column-right;
            "Mod+WheelScrollLeft".action = focus-column-left;
            "Mod+Ctrl+WheelScrollRight".action = move-column-right;
            "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

            "Mod+Shift+WheelScrollRight".action = focus-column-right;
            "Mod+Shift+WheelScrollLeft".action = focus-column-left;
            "Mod+Ctrl+Shift+WheelScrollRight".action = move-column-right;
            "Mod+Ctrl+Shift+WheelScrollLeft".action = move-column-left;

            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;
            "Mod+Ctrl+1".action.move-column-to-workspace = 1;
            "Mod+Ctrl+2".action.move-column-to-workspace = 2;
            "Mod+Ctrl+3".action.move-column-to-workspace = 3;
            "Mod+Ctrl+4".action.move-column-to-workspace = 4;
            "Mod+Ctrl+5".action.move-column-to-workspace = 5;
            "Mod+Ctrl+6".action.move-column-to-workspace = 6;
            "Mod+Ctrl+7".action.move-column-to-workspace = 7;
            "Mod+Ctrl+8".action.move-column-to-workspace = 8;
            "Mod+Ctrl+9".action.move-column-to-workspace = 9;

            "Mod+BracketLeft".action = consume-or-expel-window-left;
            "Mod+BracketRight".action = consume-or-expel-window-right;

            "Mod+Comma".action = consume-window-into-column;
            "Mod+Period".action = expel-window-from-column;

            "Mod+R".action = switch-preset-column-width;
            "Mod+Shift+R".action = switch-preset-window-height;
            "Mod+Ctrl+R".action = reset-window-height;
            "Mod+F".action = maximize-column;
            "Mod+Shift+F".action = fullscreen-window;

            "Mod+Ctrl+F".action = expand-column-to-available-width;
            "Mod+C".action = center-column;

            "Mod+Ctrl+C".action = center-visible-columns;

            "Mod+Minus".action = set-column-width "-5%";
            "Mod+Equal".action = set-column-width "+5%";

            "Mod+Shift+Minus".action = set-window-height "-5%";
            "Mod+Shift+Equal".action = set-window-height "+5%";

            "Mod+Ctrl+Space".action = toggle-window-floating;
            "Mod+Shift+Space".action = switch-focus-between-floating-and-tiling;

            "Mod+W".action = toggle-column-tabbed-display;

            "Print".action = screenshot;
            "Mod+Print" = {
              hotkey-overlay.title = "Extra screenshot/screencast script: rofi-screenshot";
              action = sh "rofi-screenshot";
            };
            "Alt+Print".action = screenshot-window;

            "Mod+Insert".action = set-dynamic-cast-window;
            "Mod+Shift+Insert".action = set-dynamic-cast-monitor;
            "Mod+Delete".action = clear-dynamic-cast-target;

            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action = sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            };

            "XF86MonBrightnessUp".action = sh "brightnessctl set 5%+";
            "XF86MonBrightnessDown".action = sh "brightnessctl set 5%-";

            "Mod+Escape" = {
              allow-inhibiting = false;
              action = toggle-keyboard-shortcuts-inhibit;
            };

            "Mod+Shift+E".action = quit;
            "Ctrl+Alt+Delete".action = quit;

            "Mod+Tab".action = focus-window-down-or-column-right;
            "Mod+Shift+Tab".action = focus-window-up-or-column-left;
          };
        debug = {
          dbus-interfaces-in-non-session-instances = [ ];
        };
        gestures.hot-corners.enable = false;
        window-rules = [
          {
            draw-border-with-background = false;
          }
          {
            matches = [
              {
                app-id = "^firefox$";
                title = "Private Browsing";
              }
            ];
            border.active.color = colors.base0E;
          }
          {
            matches = [
              {
                app-id = "^signal$";
              }
            ];
            block-out-from = "screencast";
          }
          {
            matches = [
              {
                app-id = "steam";
                title = ''r#"^notificationtoasts_\d+_desktop$"#'';
              }
            ];
            default-floating-position = {
              x = 10;
              y = 10;
              relative-to = "bottom-right";
            };
          }
          {
            matches = [ { app-id = "^xwaylandvideobridge$"; } ];
            open-floating = true;
            focus-ring.enable = false;
            opacity = 0.0;
            default-floating-position = {
              x = 0;
              y = 0;
              relative-to = "bottom-right";
            };
            min-width = 1;
            max-width = 1;
            min-height = 1;
            max-height = 1;
          }
        ];

      };
  };
}
