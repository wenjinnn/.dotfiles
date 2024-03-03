{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    outputs.homeManagerModules.ags
  ];

  home.packages = with pkgs; [
    hyprpicker
    supergfxctl
    wayshot
    wf-recorder
    imagemagick
    slurp
    tesseract
    pavucontrol
    swappy
    brightnessctl
    playerctl
    pulseaudio
    gnupg
    libsForQt5.kdeconnect-kde
    swayidle
    udiskie
    swww
    # gtklock
    # gtklock-userinfo-module
    # gtklock-powerbar-module
    # gtklock-playerctl-module
    blueberry
    cliphist
    glib
    wl-clipboard
    xdg-utils
    wl-gammactl
    unstable.xwaylandvideobridge
  ];

  xdg.desktopEntries."org.gnome.Settings" = {
    name = "Settings";
    comment = "Gnome Control Center";
    icon = "org.gnome.Settings";
    exec = "env XDG_CURRENT_DESKTOP=gnome ${pkgs.gnome.gnome-control-center}/bin/gnome-control-center";
    categories = [ "X-Preferences" ];
    terminal = false;
  };
  xdg.desktopEntries.dbeaver = {
    name = "DBeaver";
    comment = "SQL Integrated Development Environment";
    icon = "dbeaver";
    exec = "env GDK_BACKEND=x11 ${pkgs.dbeaver}/bin/dbeaver";
    categories = [ "Development" ];
    type = "Application";
    genericName = "SQL Integrated Development Environment";
  };
  home.file = {
    # ".config/gtklock/config.ini".text = ''
    #   [main]
    #   gtk-theme=adw-gtk3-dark
    #   modules=${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so;${pkgs.gtklock-playerctl-module}/lib/gtklock/playerctl-module.so;${pkgs.gtklock-userinfo-module}/lib/gtklock/userinfo-module.so
    #   time-format=%T
    # '';
  };

  systemd.user = {
    services = {
      bingwallpaper-get = {
        Unit = {
          Description = "Download bing wallpaper to target path";
        };
        Service = {
          Type = "oneshot";
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStart = "${pkgs.bingwallpaper-get}/bin/bingwallpaper-get";
          ExecStartPost = "${pkgs.swww-switch}/bin/swww-switch";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };

      };
      swww-next = {
        Unit = {
          Description = "switch newest wallpaper powered by swww";
        };
        Service = {
          Type = "oneshot";
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStart = "${pkgs.swww-switch}/bin/swww-switch";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
      swww-random = {
        Unit = {
          Description = "switch random wallpaper powered by swww";
          After = "bingwallpaper-get.service";
        };
        Service = {
          Type = "oneshot";
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStart = "${pkgs.swww-switch}/bin/swww-switch random";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
    timers = {
      bingwallpaper-get = {
        Unit = {
          Description = "Download bing wallpaper timer";
        };
        Timer = {
          OnCalendar = "hourly";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
      swww-random = {
        Unit = {
          Description = "switch random wallpaper powered by swww timer";
        };
        Timer = {
          OnUnitActiveSec = "30min";
          OnBootSec = "30min";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
    };
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      clock = true;
      indicator = true;
      font-size = 48;
      indicator-radius = 100;
      indicator-thickness = 7;
      fade-in = 0.2;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
      ring-color = "51a4e7";
      grace = 0;
      key-hl-color = "880033";
      line-color = "00000000";
      inside-color = "00000088";
      separator-color = "00000000";
      datestr = "%F, %a";
      show-failed-attempts = true;
      daemonize = true;
      indicator-caps-lock = true;
      show-keyboard-layout = false;
    };
  };

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        package = pkgs.unstable.hyprland;
        xwayland.enable = true;
        systemd.enable = true;
        settings = {
          env = [
            "XMODIFIERS, @im=fcitx"
            "QT_IM_MODULE, fcitx"
            "SDL_IM_MODULE, fcitx"
            # "QT_QPA_PLATFORMTHEME, qt5ct"
            "GDK_BACKEND, wayland,x11"
            "QT_QPA_PLATFORM, wayland;xcb"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
            "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
            "CLUTTER_BACKEND, wayland"
            "ADW_DISABLE_PORTAL, 1"
            "GDK_SCALE,2"
            "XCURSOR_SIZE, 24"
          ];
          exec-once = [
            # "sleep 1 && swww init && swww img ~/.config/eww/images/wallpaper --transition-fps 60 --transition-type random --transition-pos && systemctl --user start swww-next.timer &"
            "ags -b hypr"
            "fcitx5 -d --replace"
            "gnome-keyring-daemon --start --components=secrets"
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            "kdeconnect-indicator"
            "udiskie &"
            "swayidle -w timeout 300 'swaylock' timeout 360 'hyprctl dispatch dpms off' after-resume 'hyprctl dispatch dpms on' before-sleep 'swaylock && sleep 1 && hyprctl dispatch dpms off'"
            "libinput-gestures-setup start"
            "sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            # fix share pick https://wiki.hyprland.org/Useful-Utilities/Hyprland-desktop-portal/
            "dbus-update-activation-environment --systemd --all && systemctl --user import-environment QT_QPA_PLATFORMTHEME"
            "hyprctl dispatch exec [workspace special:monitor silent] foot btop"
            "hyprctl dispatch exec [workspace special:evolution silent] evolution"
            # "hyprctl dispatch exec [workspace special:windows silent] \"virt-manager --no-fork --show-domain-console win10 -c qemu:///system\""
          ];
          monitor = [
            ",highres,auto,auto"
            "eDP-1, addreserved, 0, 0, 0, 0"
            "eDP-1, highres,auto,2"
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
            workspace_swipe_distance = "1200px";
            workspace_swipe_fingers = 4;
            workspace_swipe_cancel_ratio = 0.2;
            workspace_swipe_min_speed_to_force = 5;
            workspace_swipe_create_new = true;
          };
          general = {
            layout = "dwindle";
            no_focus_fallback = true;
            "col.active_border" = "rgba(51a4e7ff)";
          };
          dwindle = {
            preserve_split = true;
          };
          decoration = {
	        rounding = 10;
            drop_shadow = "false";
            shadow_range = 8;
            shadow_render_power = 2;
            "col.shadow" = "rgba(00000044)";

            dim_inactive = false;

            blur = {
              enabled = true;
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
            vfr = true;
            vrr = 1;
            focus_on_activate = true;
            animate_manual_resizes = false;
            animate_mouse_windowdragging = false;
            #suppress_portal_warnings = true
            enable_swallow = true;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
            force_default_wallpaper = 0;
          };
          windowrule = [
            "float, ^(steam)$"
            "tile,title:^(WPS)(.*)$"
            # Dialogs
            "float,title:^(Open File)(.*)$"
            "float,title:^(Open Folder)(.*)$"
            "float,title:^(Save As)(.*)$"
            "float,title:^(Library)(.*)$"
            "float,title:^(xdg-desktop-portal)(.*)$"
            "nofocus,title:^(.*)(mvi)$"
          ];
          windowrulev2 = [
            "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
            "noanim,class:^(xwaylandvideobridge)$"
            "nofocus,class:^(xwaylandvideobridge)$"
            "noinitialfocus,class:^(xwaylandvideobridge)$"
          ];
          layerrule = [
            # "blur, powermenu"
            # "blur, gtk-layer-shell"
            # "ignorezero, gtk-layer-shell"
          ];
          bind = let e = "exec, ags -b hypr"; in [

            "ControlSuper, Q, killactive,"
            "ControlSuper, Space, togglefloating, "
            "ControlSuperShift, Space, pin, "
            "ControlShiftSuper, Q, exec, hyprctl kill"
            "Super, Return, exec, foot"
            "SUPER, I, exec, XDG_CURRENT_DESKTOP=GNOME gnome-control-center"
            "ControlSuperShiftAlt, E, exit,"
            ", XF86PowerOff, ${e} -t powermenu"
            "Super, Tab,     ${e} -t overview"
            "Super,Print,  ${e} -r 'recorder.start()'"
            "ControlSuper,Print,  ${e} -r 'recorder.start(true)'"
            ",Print,         ${e} -r 'recorder.screenshot(true)'"
            "Shift,Print,    ${e} -r 'recorder.screenshot()'"
            "ControlShiftSuper, P, exec, playerctl play-pause"
            "ControlAltSuper, P, exec, playerctl pause"
            "ControlShiftSuper, S, exec, playerctl pause"
            "ControlSuper, P, exec, playerctl previous"
            "ControlSuper, N, exec, playerctl next"
            "ControlSuperShiftAlt, L, exec, swaylock"
            "ControlSuperShiftAlt, D, exec, systemctl poweroff"
            # Applauncher
            "Super, D, exec, ags -b hypr -t applauncher"
            "Super, V, exec, ags -b hypr -t clipboard"
            "Super, N, exec, ags -b hypr -t datemenu"
            # Snapshot
            "SuperShift, S, exec, grim -g \"$(slurp)\" - | wl-copy"
            # Swap windows
            "SuperShift, H, movewindow, l"
            "SuperShift, L, movewindow, r"
            "SuperShift, K, movewindow, u"
            "SuperShift, J, movewindow, d"
            # Move focus
            "Super, H, movefocus, l"
            "Super, L, movefocus, r"
            "Super, K, movefocus, u"
            "Super, J, movefocus, d"
            # Workspace, window, tab switch with keyboard
            "ControlSuper, right, workspace, +1"
            "ControlSuper, left, workspace, -1"
            "ControlSuper, BracketLeft, workspace, -1"
            "ControlSuper, BracketRight, workspace, +1"
            "ControlSuper, up, workspace, -5"
            "ControlSuper, down, workspace, +5"
            "Super, Page_Down, workspace, +1"
            "Super, Page_Up, workspace, -1"
            "ControlSuper, Page_Down, workspace, +1"
            "ControlSuper, Page_Up, workspace, -1"
            "SuperShift, Page_Down, movetoworkspace, +1"
            "SuperShift, Page_Up, movetoworkspace, -1"
            "Controlsuper, L, movetoworkspace, +1"
            "Controlsuper, H, movetoworkspace, -1"
            "SuperShift, mouse_down, movetoworkspace, -1"
            "SuperShift, mouse_up, movetoworkspace, +1"
            # Fullscreen
            "Super, F, fullscreen, 1"
            "SuperShift, F, fullscreen, 0"
            "ControlSuper, F, fakefullscreen, 0"
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
            "Super, S, togglespecialworkspace"
            "Super, M, togglespecialworkspace, monitor"
            "Super, W, togglespecialworkspace, windows"
            "Super, E, togglespecialworkspace, evolution"
            # "Super, C, togglespecialworkspace, kdeconnect"
            # bind = SUPER, Tab, cyclenext
            # "Super, Tab, exec, ags -b hypr -t overview"
            # "Super, Tab, bringactivetotop,   # bring it to the top"
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
            "SUPER, Minus, splitratio, -0.1"
            "SUPER, Equal, splitratio, 0.1"
            "SUPER, Semicolon, splitratio, -0.1"
            "SUPER, Apostrophe, splitratio, 0.1"
          ];
          bindr = [
            "ControlSuperShiftAlt, R, exec, ags -b hypr quit; ags -b hypr"
          ];
          bindl = [
            ",Print,exec,grim - | wl-copy"
            "ControlSuperShiftAlt, S, exec, systemctl suspend"
            ",XF86AudioPlay,    exec, playerctl play-pause"
            ",XF86AudioStop,    exec, playerctl pause"
            ",XF86AudioPause,   exec, playerctl pause"
            ",XF86AudioPrev,    exec, playerctl previous"
            ",XF86AudioNext,    exec, playerctl next"
            ",XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
          ];
          bindle =  [
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
