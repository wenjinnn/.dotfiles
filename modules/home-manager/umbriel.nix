{
  config,
  mainMonitor ? "eDP-1",
  pkgs,
  ...
}:
let
  palette = config.lib.stylix.colors.withHashtag;
  rgba = color: alpha: "${color}${alpha}";
  settings = {
    include.files = [ ];

    general = {
      autostart = [
        "bash -c \"echo 'Xft.dpi: 192' | xrdb -merge\""
      ];
      mod_key = "Super";
      xwayland = true;
      xwayland_native_resolution = true;
      show_cheatsheet = false;
      focus_on_activate = false;
    };

    workspaces.back_and_forth = false;

    colors = {
      background = rgba palette.base00 "F0";
      text_primary = rgba palette.base05 "FF";
      text_muted = rgba palette.base04 "FF";
      accent_primary = rgba palette.base0D "FF";
      accent_secondary = rgba palette.base0A "FF";
      warning = rgba palette.base0A "FF";
      error = rgba palette.base08 "FF";
      insert_hint = rgba palette.base0D "80";
      backdrop = rgba palette.base00 "FF";
      shadow = rgba palette.base00 "70";
      border = {
        focused = rgba palette.base0D "FF";
        unfocused = "#00000000";
        outer = rgba palette.base02 "FF";
      };
      overview = {
        background_tint = rgba palette.base00 "30";
        workspace_background = rgba palette.base00 "44";
      };
    };

    appearance = {
      prefer_no_csd = true;
      border_width = 2;
      outer_border_width = 0;
      corner_radius = 12;
      blur = {
        enabled = true;
        optimized = true;
        passes = 3;
        radius = 3;
        noise = 0.02;
        brightness = 0.9;
        contrast = 0.9;
        saturation = 1.1;
      };
      shadow = {
        enabled = false;
        softness = 30;
        offset_x = 0;
        offset_y = 5;
      };
    };

    animation.duration_ms = 250;

    overview.zoom = 0.5;

    hot_corners = {
      top_left = {
        enabled = false;
        delay_ms = 500;
        action = "overview-open";
      };
      top_right = {
        enabled = false;
        delay_ms = 500;
        action = "overview-close";
      };
      bottom_left = {
        enabled = false;
        delay_ms = 500;
        action = "overview-toggle";
      };
      bottom_right = {
        enabled = false;
        delay_ms = 500;
        action = "spawn notify-send 'Bottom right'";
      };
    };

    layout = {
      mode = "scrolling";
      gap = 4;
      extent_presets = [
        0.333
        0.5
        0.667
      ];
      scrolling = {
        default_extent_fraction = 0.5;
        # niri uses center-focused-column "never".
        center_underfull_strip = false;
      };
    };

    output = {
      "${mainMonitor}" = {
        scale = 2.5;
        transform = "normal";
        position = [
          0
          0
        ];
        vrr = "always";
        hdr = "on";
      };
      "HDMI-A-1" = {
        scale = 2.5;
        transform = "normal";
        # At 2.5x, HDMI is 1536x864 logical pixels, centered above eDP.
        position = [
          0
          (0 - 864)
        ];
        vrr = "always";
        hdr = "on";
      };
    };

    input = {
      middle_click_paste = true;
      keyboard = {
        layout = "";
        variant = "";
        options = "";
        repeat_rate = 25;
        repeat_delay = 600;
      };
      touchpad = {
        tap = true;
        natural_scroll = true;
      };
      mouse = {
        accel_profile = "flat";
        sensitivity = 0.0;
        scroll_wheel_step = 60;
      };
      tablet.enabled = true;
      cursor = {
        theme = "default";
        size = 24;
        hardware_cursor = true;
        hide_when_typing = false;
        hide_timeout_ms = 0;
      };
      focus.follows_mouse = false;
    };

    keybinds = {
      # Niri-compatible application and shell actions.
      "Alt+Print" = "spawn noctalia msg screenshot-fullscreen pick";
      "Ctrl+Alt+Delete" = "session-quit skip-confirmation";
      "Ctrl+Print" = "spawn noctalia msg screenshot-fullscreen all";
      "Print" = "spawn noctalia msg screenshot-region";
      "Mod+A" = "spawn wl-kbptr -o modes=floating,click -o mode_floating.source=detect";
      "Mod+B" = "spawn wayscriber -a";
      "Mod+Ctrl+P" = "spawn noctalia msg media toggle";
      "Mod+Ctrl+S" = "spawn noctalia msg settings-toggle";
      "Mod+Z" = "spawn noctalia msg notification-clear-active";
      "Mod+Ctrl+Shift+P" = "spawn noctalia msg panel-toggle session";
      "Mod+Return" = "spawn ghostty";
      "Mod+D" = "spawn noctalia msg panel-toggle launcher";
      "Mod+E" = "spawn noctalia msg panel-toggle control-center";
      "Mod+M" = "spawn noctalia msg panel-toggle control-center system";
      "Mod+N" = "spawn noctalia msg panel-toggle control-center notifications";
      "Mod+Y" = "spawn noctalia msg power-cycle";
      "Mod+X" = "window-toggle-pinned";
      "Mod+U" = "window-toggle-maximize-to-edges";
      "Mod+Shift+N" = "spawn noctalia msg media next";
      "Mod+Alt+N" = "spawn noctalia msg media next-player";
      "Mod+Shift+P" = "spawn noctalia msg media previous";
      "Mod+Alt+P" = "spawn noctalia msg media previous-player";
      "Mod+Shift+W" = "spawn noctalia msg wallpaper-random";
      "Mod+V" = "spawn noctalia msg panel-toggle clipboard";
      "Mod+W" = "spawn noctalia msg panel-toggle wallpaper";
      "Mod+T" = "spawn noctalia msg notification-invoke-latest";
      "Super+Alt+L" = "spawn noctalia msg session lock";
      "XF86AudioLowerVolume" = "spawn noctalia msg volume-down 5";
      "XF86AudioMicMute" = "spawn wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      "XF86AudioMute" = "spawn noctalia msg volume-mute";
      "XF86AudioRaiseVolume" = "spawn noctalia msg volume-up 5";
      "XF86MonBrightnessDown" = "spawn noctalia msg brightness-down 5";
      "XF86MonBrightnessUp" = "spawn noctalia msg brightness-up 5";

      # Focus and window movement.
      "Mod+Shift+Tab" = "window-focus-next";
      "Mod+Ctrl+Down" = "output-focus-down";
      "Mod+Ctrl+H" = "output-focus-left";
      "Mod+Ctrl+J" = "output-focus-down";
      "Mod+Ctrl+K" = "output-focus-up";
      "Mod+Ctrl+L" = "output-focus-right";
      "Mod+Ctrl+Left" = "output-focus-left";
      "Mod+Ctrl+Right" = "output-focus-right";
      "Mod+Ctrl+Up" = "output-focus-up";
      "Mod+Down" = "window-focus-down";
      "Mod+H" = "window-focus-left";
      "Mod+J" = "window-focus-down";
      "Mod+K" = "window-focus-up";
      "Mod+L" = "window-focus-right";
      "Mod+Left" = "window-focus-left";
      "Mod+Right" = "window-focus-right";
      "Mod+Up" = "window-focus-up";
      "Mod+C" = "window-center";
      "Mod+BracketLeft" = "window-consume-left";
      "Mod+BracketRight" = "window-consume-or-expel-right";
      "Mod+Comma" = "window-consume-left";
      "Mod+Period" = "window-consume-or-expel-right";
      "Mod+Ctrl+F" = "window-set-primary-extent 1.0";
      "Mod+Equal" = "window-modify-primary-extent +0.05";
      "Mod+Minus" = "window-modify-primary-extent -0.05";
      "Mod+Q" = "window-close";
      "Mod+R" = "window-cycle-primary-extent";
      "Mod+S" = "window-toggle-floating";
      "Mod+F" = "window-toggle-maximize";
      "Mod+Shift+F" = "window-toggle-fullscreen";
      "Mod+Ctrl+Shift+F" = "window-toggle-fullscreen";
      "Mod+Shift+Down" = "window-move-down";
      "Mod+Shift+H" = "column-move-left";
      "Mod+Shift+J" = "window-move-down";
      "Mod+Shift+K" = "window-move-up";
      "Mod+Shift+L" = "column-move-right";
      "Mod+Shift+Left" = "column-move-left";
      "Mod+Shift+Right" = "column-move-right";
      "Mod+Shift+Up" = "window-move-up";
      "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";
      "Mod+Shift+Ctrl+H" = "column-move-to-output-left";
      "Mod+Shift+Ctrl+J" = "column-move-to-output-down";
      "Mod+Shift+Ctrl+K" = "column-move-to-output-up";
      "Mod+Shift+Ctrl+L" = "column-move-to-output-right";
      "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
      "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";
      "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
      "Mod+Ctrl+Page_Down" = "window-move-to-workspace-next";
      "Mod+Ctrl+Page_Up" = "window-move-to-workspace-previous";
      "Mod+Ctrl+I" = "window-move-to-workspace-previous";
      "Mod+Ctrl+O" = "window-move-to-workspace-next";
      "Mod+I" = "workspace-previous";
      "Mod+O" = "workspace-next";
      "Mod+Page_Down" = "workspace-next";
      "Mod+Page_Up" = "workspace-previous";
      "Mod+Shift+Slash" = "cheatsheet-open";
      "Mod+Tab" = "overview-toggle";
      # "Alt+Tab" = "scratchpad-focus-next";
      "Alt+Tab" = "scratchpad-toggle";
      "Mod+Shift+Space" = "window-move-to-scratchpad";
      "Mod+Ctrl+Space" = "window-restore-from-scratchpad";
      "Mod+Ctrl+Escape" = "session-quit";
      "Mod+Shift+E" = "session-quit skip-confirmation";

      # Workspaces.
      "Mod+1" = "workspace-switch 1";
      "Mod+2" = "workspace-switch 2";
      "Mod+3" = "workspace-switch 3";
      "Mod+4" = "workspace-switch 4";
      "Mod+5" = "workspace-switch 5";
      "Mod+6" = "workspace-switch 6";
      "Mod+7" = "workspace-switch 7";
      "Mod+8" = "workspace-switch 8";
      "Mod+9" = "workspace-switch 9";
      "Mod+Shift+1" = "window-move-to-workspace 1";
      "Mod+Shift+2" = "window-move-to-workspace 2";
      "Mod+Shift+3" = "window-move-to-workspace 3";
      "Mod+Shift+4" = "window-move-to-workspace 4";
      "Mod+Shift+5" = "window-move-to-workspace 5";
      "Mod+Shift+6" = "window-move-to-workspace 6";
      "Mod+Shift+7" = "window-move-to-workspace 7";
      "Mod+Shift+8" = "window-move-to-workspace 8";
      "Mod+Shift+9" = "window-move-to-workspace 9";
      "Mod+KP_1" = "workspace-switch 1";
      "Mod+KP_2" = "workspace-switch 2";
      "Mod+KP_3" = "workspace-switch 3";
      "Mod+KP_4" = "workspace-switch 4";
      "Mod+KP_5" = "workspace-switch 5";
      "Mod+KP_6" = "workspace-switch 6";
      "Mod+KP_7" = "workspace-switch 7";
      "Mod+KP_8" = "workspace-switch 8";
      "Mod+KP_9" = "workspace-switch 9";
      "Mod+Shift+KP_1" = "window-move-to-workspace 1";
      "Mod+Shift+KP_2" = "window-move-to-workspace 2";
      "Mod+Shift+KP_3" = "window-move-to-workspace 3";
      "Mod+Shift+KP_4" = "window-move-to-workspace 4";
      "Mod+Shift+KP_5" = "window-move-to-workspace 5";
      "Mod+Shift+KP_6" = "window-move-to-workspace 6";
      "Mod+Shift+KP_7" = "window-move-to-workspace 7";
      "Mod+Shift+KP_8" = "window-move-to-workspace 8";
      "Mod+Shift+KP_9" = "window-move-to-workspace 9";
      "Mod+WheelUp" = "workspace-previous";
      "Mod+WheelDown" = "workspace-next";
      "Mod+WheelLeft" = "window-focus-left";
      "Mod+WheelRight" = "window-focus-right";
      "Mod+Ctrl+WheelUp" = "workspace-previous";
      "Mod+Ctrl+WheelDown" = "window-move-to-workspace-next";
      "Mod+Ctrl+WheelLeft" = "column-move-left";
      "Mod+Ctrl+WheelRight" = "column-move-right";
      "Mod+Shift+WheelLeft" = "window-focus-left";
      "Mod+Shift+WheelRight" = "window-focus-right";
      "Mod+Ctrl+Shift+WheelLeft" = "column-move-left";
      "Mod+Ctrl+Shift+WheelRight" = "column-move-right";
    };

    window_rule = [
      {
        match.app_id = "^dev.noctalia.Noctalia$";
        default_floating = true;
        default_floating_size_px = {
          width = 1020;
          height = 900;
        };
      }
      {
        match.app_id = "^dev.noctalia.UmbrielSharePicker$";
        default_floating = true;
        default_floating_size_px = {
          width = 800;
          height = 600;
        };
      }
      {
        match.content_type = "game";
        default_fullscreen = true;
        default_output = "HDMI-A-1";
      }
      {
        match.app_id = "^steam_app_[0-9]+$";
        default_fullscreen = true;
        default_output = "HDMI-A-1";
      }
      {
        match.app_id = "steam";
        match.title = "^notificationtoasts_[0-9]+_desktop$";
        default_floating = true;
        default_focused = false;
        default_output = "HDMI-A-1";
        default_position = {
          x = 50;
          y = 50;
          anchor = "bottom_right";
        };
      }
      {
        match.app_id = "steam";
        default_output = "HDMI-A-1";
      }
      # {
      #   match.app_id = "wemeetapp";
      #   match.title = "wemeetapp";
      #   default_floating = true;
      #   default_focused = false;
      #   default_position = {
      #     x = 50;
      #     y = 50;
      #     anchor = "bottom_right";
      #   };
      # }
      # {
      #   match.app_id = "wemeetapp";
      #   match.title = "EmojiFloatWnd";
      #   default_floating = true;
      #   default_focused = false;
      #   default_position = {
      #     x = 50;
      #     y = 50;
      #     anchor = "bottom_right";
      #   };
      # }
      {
        match.app_id = "wps";
        match.title = "wps";
        default_floating = true;
      }
      {
        match.app_id = "^xwaylandvideobridge$";
        opacity = 0.0;
        default_floating_size_px = {
          width = 1;
          height = 1;
        };
        default_floating = true;
        default_position = {
          x = 0;
          y = 0;
          anchor = "bottom_right";
        };
      }
      # {
      #   match.app_id = "wemeetapp";
      #   match.title = "wemeetapp";
      #   opacity = 0.0;
      #   default_size = [
      #     1
      #     1
      #   ];
      #   default_floating = true;
      #   default_position = {
      #     x = 0;
      #     y = 0;
      #     anchor = "bottom_right";
      #   };
      # }
      {
        match.app_id = "^wemeetapp$";
        match.title = "^wemeetapp$";
        match.is_floating = false;
        opacity = 0.0;
      }
    ];

    layer_rule = [
      {
        match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";
        blur = true;
        blur_ignore_alpha = 0.5;
        blur_optimized = false;
      }
    ];
  };
in
{
  xdg.configFile."umbriel/config.toml".source =
    (pkgs.formats.toml { }).generate "umbriel-config.toml"
      settings;
}
