{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  username,
  ...
}:
let
  mainMonitor = "eDP-1";
  pointer = config.home.pointerCursor;
  cursorName = "Adwaita";
  cursorPackage = pkgs.adwaita-icon-theme;
in
{
  imports = with outputs.homeManagerModules; [
    waybar
    rofi
    wallpaper
    dunst
    udiskie
    cliphist
    kdeconnect
  ];

  xdg.dataFile."icons/${cursorName}".source = "${cursorPackage}/share/icons/${cursorName}";

  home.packages = with pkgs; [
    xdg-utils
    kdePackages.xwaylandvideobridge
    hyprpaper
    hyprcursor
    hyprpicker
    hyprsunset
  ];

  services = {
    hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = true;
        # .config/background is a symlink to the current wallpaper, setup by wallpaper-random script
        preload = [ "${config.home.homeDirectory}/.config/background" ];
        wallpaper = [ ", ${config.home.homeDirectory}/.config/background" ];
      };
    };
    hyprpolkitagent.enable = true;
    hyprsunset = {
      enable = true;
      transitions = {
        sunrise = {
          calendar = "*-*-* 07..18:00:00";
          requests = [
            [
              "temperature"
              "5500"
            ]
          ];
        };
        sunset = {
          calendar = "*-*-* 19..23:00:00";
          requests = [
            [
              "temperature"
              "3000"
            ]
          ];
        };
      };
    };
    # hypridle configuration
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session && hyprctl dispatch dpms off";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 360;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  systemd.user = {
    timers = {
      hyprsunset-sunrise = {
        Timer = {
          OnBootSec = "1min";
        };
      };
      hyprsunset-sunset = {
        Timer = {
          OnBootSec = "1min";
        };
      };
    };
    services = {
      hyprsunset-sunrise = {
        Install = {
          WantedBy = [
            "default.target"
            "sleep.target"
          ];
        };
      };
      hyprsunset-sunset = {
        Install = {
          WantedBy = [
            "default.target"
            "sleep.target"
          ];
        };
      };
    };
  };

  # hyprlock configuration
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          path = "screenshot";
          blur_passes = 5;
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
          monitor = mainMonitor;
          size = "600, 120";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          # outer_color = "rgba(255, 255, 255, 0)";
          # inner_color = "rgba(255, 255, 255, 0.1)";
          # font_color = "rgb(200, 200, 200)";
          fade_on_empty = true;
          placeholder_text = "🔒 Enter Pass";
          hide_input = false;
          position = "0, -210";
          halign = "center";
          valign = "center";
        }
      ];
      # USER-BOX
      shape = [
        {
          monitor = mainMonitor;
          size = "600, 120";
          color = "rgba(255, 255, 255, .1)";
          rounding = -1;
          border_size = 0;
          border_color = "rgba(253, 198, 135, 0)";
          rotate = 0;
          xray = false;

          position = "0, -65";
          halign = "center";
          valign = "center";
        }
      ];
      label = [
        # Day-Month-Date
        {
          monitor = mainMonitor;
          text = "cmd[update:1000] echo -e \"$(date +\"%A, %B %d\")\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 50;
          position = "0, 700";
          halign = "center";
          valign = "center";
        }
        # Time
        {
          monitor = mainMonitor;
          text = "cmd[update:1000] echo \"<span>$(date +\"- %H:%M -\")</span>\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 240;
          position = "0, 500";
          halign = "center";
          valign = "center";
        }
        # USER
        {
          monitor = mainMonitor;
          text = "  $USER";
          color = "rgba(216, 222, 233, 0.80)";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          font_size = 36;
          position = "0, -65";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # hyprland configuration
  wayland = {
    windowManager = {
      hyprland = {
        package = inputs.hyprland.packages.${pkgs.system}.default;
        enable = true;
        xwayland.enable = true;
        systemd = {
          enable = true;
          variables = [
            "--all"
          ];
        };
        plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
          hyprexpo
          hyprscrolling
        ];
        settings = {
          plugin = {
            hyprexpo = {
              columns = 2;
              gap_size = 10;
              workspace_method = "center first"; # [center/first] [workspace] e.g. first 1 or center m+1

              enable_gesture = true; # laptop touchpad
              gesture_fingers = 3; # 3 or 4
              gesture_distance = 300; # how far is the "max"
              gesture_positive = true; # positive = swipe down. Negative = swipe up.
            };
            hyprscrolling = {
              fullscreen_on_one_column = true;
              focus_fit_method = 1;
            };
          };
          env = [
            "XMODIFIERS, @im=fcitx"
            "QT_IM_MODULE, fcitx"
            "SDL_IM_MODULE, fcitx"
            "QT_QPA_PLATFORMTHEME, qt5ct"
            "GDK_BACKEND, wayland,x11"
            "QT_QPA_PLATFORM, wayland;xcb"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
            "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
            "CLUTTER_BACKEND, wayland"
            "ADW_DISABLE_PORTAL, 1"
            "GDK_SCALE,2"
            "XCURSOR_SIZE, ${toString pointer.size}"
            "HYPRCURSOR_THEME, ${cursorName}"
            "HYPRCURSOR_SIZE, ${toString pointer.size}"
          ];
          exec-once = [
            # xrdb dpi scale have batter effect in 4k screen
            "echo 'Xft.dpi: 192' | xrdb -merge"
            "hyprctl dispatch exec [workspace special:monitor silent] foot btop"
            # set cursor
            "hyprctl setcursor ${cursorName} ${toString pointer.size}"
          ];
          monitor = [
            ",preferred,auto,auto"
          ];
          input = {
            force_no_accel = false;
            kb_layout = "us";
            follow_mouse = 1;
            numlock_by_default = true;
            scroll_method = "2fg";

            touchpad = {
              natural_scroll = "yes";
              disable_while_typing = true;
              clickfinger_behavior = true;
              scroll_factor = 0.7;
            };
          };
          gestures = {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            workspace_swipe = true;
            workspace_swipe_distance = 1200;
            workspace_swipe_fingers = 4;
            workspace_swipe_cancel_ratio = 0.2;
            workspace_swipe_min_speed_to_force = 5;
            workspace_swipe_create_new = true;
          };
          general = {
            border_size = 2;
            gaps_out = 10;
            gaps_in = 5;
            layout = "scrolling";
            no_focus_fallback = true;
            resize_on_border = true;
            # "col.active_border" = "rgba(51a4e7ff)";
          };
          dwindle = {
            preserve_split = true;
          };
          decoration = {
            shadow = {
              enabled = false;
              range = 8;
              render_power = 2;
              # color = "rgba(00000044)";
            };
            # "col.shadow" = "rgba(00000044)";

            dim_inactive = false;

            blur = {
              enabled = false;
              size = 8;
              passes = 3;
              new_optimizations = "on";
              noise = 0.01;
              contrast = 0.9;
              brightness = 0.8;
              xray = true;
            };
          };
          animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 5, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };
          xwayland = {
            force_zero_scaling = true;
          };
          misc = {
            vrr = 1;
            enable_anr_dialog = false;
            focus_on_activate = true;
            animate_manual_resizes = false;
            animate_mouse_windowdragging = false;
            #suppress_portal_warnings = true
            enable_swallow = true;
            key_press_enables_dpms = true;
            force_default_wallpaper = 0;
          };
          workspace = [
            "w[tv1], gapsout:0, gapsin:0"
            "f[1], gapsout:0, gapsin:0"
          ];
          windowrule = [
            "tile,title:^(WPS)(.*)$"
            "tile,title:^(微信)(.*)$"
            "tile,title:^(钉钉)(.*)$"
            # Dialogs
            "float,title:^(Open File)(.*)$"
            "float,title:^(Open Folder)(.*)$"
            "float,title:^(Save As)(.*)$"
            "float,title:^(Library)(.*)$"
            "float,title:^(xdg-desktop-portal)(.*)$"
            "nofocus,title:^(.*)(mvi)$"
            "opacity 0.0 override,class:^(xwaylandvideobridge)$"
            "noanim,class:^(xwaylandvideobridge)$"
            "nofocus,class:^(xwaylandvideobridge)$"
            "noinitialfocus,class:^(xwaylandvideobridge)$"
            "maxsize 1 1,class:^(xwaylandvideobridge)$"
            "bordersize 0, floating:0, onworkspace:w[tv1]"
            "rounding 0, floating:0, onworkspace:w[tv1]"
            "bordersize 0, floating:0, onworkspace:f[1]"
            "rounding 0, floating:0, onworkspace:f[1]"
          ];
          layerrule = [
            # "blur, powermenu"
            # "blur, gtk-layer-shell"
            # "ignorezero, gtk-layer-shell"
          ];
          bind =
            let
              rofi-cliphist = "rofi -modi clipboard:${pkgs.cliphist}/bin/cliphist-rofi-img -show clipboard -show-icons";
            in
            [
              "Super, Q, killactive,"
              "ControlSuper, Space, togglefloating, "
              "ControlSuperShift, Space, pin, "
              "ControlShiftSuper, Q, exec, hyprctl kill"
              "Super, Return, exec, footclient"
              "ControlSuperShiftAlt, E, exit,"
              # ", XF86PowerOff, rofi-power-menu"
              # Snapshot
              # "SuperShift, S, exec, grim -g \"$(slurp)\" - | wl-copy"
              # TODO extra to a script
              "Super,Print, exec, rofi-screenshot"
              ",Print, exec, rofi-screenshot -I"
              "ControlShiftSuper, P, exec, playerctl play-pause"
              "ControlAltSuper, P, exec, playerctl pause"
              "ControlShiftSuper, S, exec, playerctl pause"
              "ControlSuper, P, exec, playerctl previous"
              "ControlSuper, N, exec, playerctl next"
              "ControlSuperShiftAlt, L, exec, loginctl lock-session"
              # launcher
              "Super, D, exec, rofi -show drun"
              "Super, U, exec, rofi-systemd"
              "Super, B, exec, bzmenu -l rofi"
              "AltSuper, P, exec, hyprpicker | wl-copy"
              "Super, P, exec, rofi-pass"
              "Super, A, exec, dunstctl context"
              "ControlSuper, A, exec, rofi-pulse-select sink"
              "ShiftSuper, A, exec, rofi-pulse-select source"
              "Super, E, exec, rofimoji"
              "Super, M, togglespecialworkspace, monitor"
              "Super, V, exec, ${rofi-cliphist}"
              "Super, N, exec, networkmanager_dmenu"
              "ControlShiftSuperAlt, P, exec, rofi -show power-menu -modi power-menu:rofi-power-menu"
              # Swap windows
              "SuperShift, L, layoutmsg, movewindowto r"
              "SuperShift, H, layoutmsg, movewindowto l"
              "SuperShift, K, layoutmsg, movewindowto u"
              "SuperShift, J, layoutmsg, movewindowto d"
              # Move focus
              "Super, L, layoutmsg, focus r"
              "Super, H, layoutmsg, focus l"
              "Super, K, layoutmsg, focus u"
              "Super, J, layoutmsg, focus d"
              # Workspace, window, tab switch with keyboard
              "ControlSuper, right, workspace, +1"
              "ControlSuper, left, workspace, -1"
              "ControlSuper, BracketLeft, workspace, -1"
              "ControlSuper, BracketRight, workspace, +1"
              "ControlSuper, L, workspace, +1"
              "ControlSuper, H, workspace, -1"
              "ControlSuper, up, workspace, -5"
              "ControlSuper, down, workspace, +5"
              "Super, Page_Down, workspace, +1"
              "Super, Page_Up, workspace, -1"
              "SuperShift, Page_Down, layoutmsg, move +col"
              "SuperShift, Page_Up, layoutmsg, move -col"
              "ControlShiftSuper, L, movetoworkspace, +1"
              "ControlShiftSuper, H, movetoworkspace, -1"
              "ShiftSuper, P, layoutmsg, promote"
              "AltSuper, L, movecurrentworkspacetomonitor, +1"
              "AltSuper, H, movecurrentworkspacetomonitor, -1"
              "SuperShift, mouse_down, movetoworkspace, -1"
              "SuperShift, mouse_up, movetoworkspace, +1"
              "ControlShiftSuper, F, layoutmsg, fit active"
              # Fullscreen
              "Super, F, fullscreen, 1"
              "SuperShift, F, fullscreen, 0"
              "ControlSuper, F, fullscreenstate, 3"
              # Switching
              "Super, 1, workspace, 1"
              "Super, 2, workspace, 2"
              "Super, 3, workspace, 3"
              "Super, 4, workspace, 4"
              "Super, 5, workspace, 5"
              "Super, 6, workspace, 6"
              "Super, 7, workspace, 7"
              "Super, 8, workspace, 8"
              "Super, 9, workspace, 9"
              "Super, 0, workspace, 10"
              "ShiftSuper, S, togglespecialworkspace"
              "Alt, Tab, cyclenext"
              "Super, Tab, hyprexpo:expo, toggle"
              "Super, T, bringactivetotop"
              # "Super, C, togglespecialworkspace, kdeconnect"
              # Move window to workspace Control + Super + [0-9]
              "ControlSuper, 1, movetoworkspacesilent, 1"
              "ControlSuper, 2, movetoworkspacesilent, 2"
              "ControlSuper, 3, movetoworkspacesilent, 3"
              "ControlSuper, 4, movetoworkspacesilent, 4"
              "ControlSuper, 5, movetoworkspacesilent, 5"
              "ControlSuper, 6, movetoworkspacesilent, 6"
              "ControlSuper, 7, movetoworkspacesilent, 7"
              "ControlSuper, 8, movetoworkspacesilent, 8"
              "ControlSuper, 9, movetoworkspacesilent, 9"
              "ControlSuper, 0, movetoworkspacesilent, 10"
              "ControlShiftSuper, Up, movetoworkspacesilent, special"
              "ControlSuper, S, movetoworkspacesilent, special"
              # Scroll through existing workspaces with (Control) + Super + scroll
              "Super, mouse_up, workspace, +1"
              "Super, mouse_down, workspace, -1"
              "ControlSuper, mouse_up, workspace, +1"
              "ControlSuper, mouse_down, workspace, -1"
              # Move/resize windows with Super + LMB/RMB and dragging
              "ControlSuper, Backslash, resizeactive, exact 640 480"
            ];
          bindm = [
            # Move/resize windows with Super + LMB/RMB and dragging
            "Super, mouse:272, movewindow"
            "Super, mouse:273, resizewindow"
            "Super, mouse:274, movewindow"
            "Super, Z, movewindow"
          ];
          binde = [
            # Window split ratio
            "Super, Minus, layoutmsg, colresize -0.1"
            "Super, Equal, layoutmsg, colresize 0.1"
            "Super, Semicolon, layoutmsg, colresize -conf"
            "Super, Apostrophe, layoutmsg, colresize +conf"
            "ControlSuper, Semicolon, layoutmsg, colresize all -0.1"
            "ControlSuper, Apostrophe, layoutmsg, colresize all 0.1"
          ];
          bindl = [
            # ",Print,exec,grim - | wl-copy"
            "ControlSuperShiftAlt, S, exec, systemctl suspend"
            ",XF86AudioPlay,    exec, playerctl play-pause"
            ",XF86AudioStop,    exec, playerctl pause"
            ",XF86AudioPause,   exec, playerctl pause"
            ",XF86AudioPrev,    exec, playerctl previous"
            ",XF86AudioNext,    exec, playerctl next"
            ",XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
          ];
          bindle = [
            ",XF86MonBrightnessUp,   exec, brightnessctl set +5%"
            ",XF86MonBrightnessDown, exec, brightnessctl set  5%-"
            ",XF86KbdBrightnessUp,   exec, brightnessctl -d asus::kbd_backlight set +1"
            ",XF86KbdBrightnessDown, exec, brightnessctl -d asus::kbd_backlight set  1-"
            ",XF86AudioRaiseVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
            ",XF86AudioLowerVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
          ];
        };
      };
    };
  };
}
