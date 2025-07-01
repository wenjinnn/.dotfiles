{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cava
  ];

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
    };
    settings = {
      mainBar = {
        spacing = 0;
        layer = "top";
        position = "left";
        modules-left = [
          "custom/os"
          "gamemode"
          "niri/workspaces"
          "hyprland/window"
          # "niri/window"
          "hyprland/submap"
        ];
        modules-center = [
          "privacy"
          "mpris"
          "clock"
          "idle_inhibitor"
          "custom/recorder"
        ];
        modules-right = [
          "tray"
          "cpu"
          "memory"
          "temperature"
          "disk"
          "network#speed"
          "network"
          "bluetooth"
          "pulseaudio"
          "backlight"
          "battery"
          "custom/power"
        ];
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        tray = {
          spacing = 4;
          show-passive-items = true;
        };
        clock = {
          format = "{:%m\n%d\n\n<b>%H\n%M\n%S</b>}";
          interval = 1;
          format-alt = "{:%A, %B %d, %Y (%R)}  ";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            "on-click-right" = "mode";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
        };
        "hyprland/window" = {
          icon = true;
          icon-size = 18;
        };
        "niri/window" = {
          format = "{}";
          max-length = 10;
          icon = true;
          icon-size = 14;
        };
        "hyprland/submap" = {
          format = "✌️ {}";
          max-length = 8;
          tooltip = false;
        };
        "hyprland/language" = {
          format = "{}";
        };
        "hyprland/workspaces" = {
          format = "<sub>{icon}</sub>{windows}";
          # format-window-separator = "\n";
          window-rewrite-default = "";
          window-rewrite = {
            "title<.*youtube.*>" = "";
            "class<firefox>" = "";
            "class<microsoft-edge>" = "󰇩";
            "class<code>" = "󰨞";
            "class<xwaylandvideobridge>" = "󰍹";
            "foot" = "";
            "class<imv>" = "";
            "zathura" = "";
            "nautilus" = "󰪶";
            "steam" = "";
            "dbeaver" = "";
            "mpv" = "";
            "libreoffice" = "󰏆";
            "微信" = "";
            "QQ" = "";
            "kdeconnect" = "";
          };
          show-special = true;
        };
        cpu = {
          format = "{usage}";
        };
        memory = {
          format = "{}";
        };
        disk = {
          interval = 30;
          format = "{percentage_used}";
          path = "/";
        };
        cava = {
          # cava_config = "$XDG_CONFIG_HOME/cava/cava.conf"; # 可选路径
          framerate = 30;
          autosens = 1;
          sensitivity = 100;
          bars = 14;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          method = "pulse";
          source = "auto";
          stereo = true;
          reverse = false;
          bar_delimiter = 0;
          monstercat = false;
          waves = false;
          noise_reduction = 0.77;
          input_delay = 2;
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          actions = {
            "on-click-right" = "mode";
          };
        };
        network = {
          on-click-middle = "rofi-network-manager";
          on-click-right = "nm-connection-editor";
          format-wifi = "󰖩";
          format-ethernet = "";
          tooltip-format = "{ifname} via {gwaddr} \n{essid} ({signalStrength}%) ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        "network#speed" = {
          interval = 2;
          format-wifi = "󰡍";
          format-ethernet = "󰡍";
          tooltip-format = "Total: {bandwidthTotalBytes}: {bandwidthUpBytes}/{bandwidthDownBytes}";
          format-linked = "󰡍";
          format-disconnected = "⚠";
          format-alt = "Total: {bandwidthTotalBytes}: {bandwidthUpBytes}/{bandwidthDownBytes}";
        };
        backlight = {
          format = "{icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
        };
        temperature = {
          thermal-zone = 5;
          critical-threshold = 80;
          format = "{temperatureC}";
          format-icons = [
            ""
            ""
            ""
          ];
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-full = "{icon}";
          format-charging = "";
          format-plugged = "";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        privacy = {
          icon-spacing = 0;
          icon-size = 14;
          transition-duration = 250;
          expand = true;
          modules = [
            {
              type = "screenshare";
              tooltip = true;
              tooltip-icon-size = 18;
            }
            {
              type = "audio-out";
              tooltip = true;
              tooltip-icon-size = 18;
            }
            {
              type = "audio-in";
              tooltip = true;
              tooltip-icon-size = 18;
            }
          ];
        };
        bluetooth = {
          on-click = "rofi-bluetooth";
          on-click-right = "blueberry";
          format = "";
          format-disabled = "󰥊";
          format-off = "󰂲";
          format-on = "󰂯";
          format-connected = "󰂱";
          format-no-controller = "󰥊";
          format-connected-battery = "󰥉";
          # format-device-preference = [ "device1", "device2" ];  # preference list deciding the displayed device
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };
        power-profiles-daemon = {
          format = "{icon}";
          "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          "format-icons" = {
            default = "";
            performance = "";
            balanced = "";
            "power-saver" = "";
          };
        };
        pulseaudio = {
          format = "{icon}\n{format_source}";
          tooltip-format = "{volume}\n{desc}";
          "format-bluetooth" = "{icon}";
          "format-bluetooth-muted" = "󰝟\n{icon}";
          "format-muted" = "\n{format_source}";
          "format-source" = "󰍬";
          "format-source-muted" = "󰍭";
          "format-icons" = {
            headphone = "";
            "hands-free" = "󰋏";
            headset = "󰋎";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };
        wireplumber = {
          format = "{icon}";
          format-muted = "";
          on-click = "helvum";
          format-icons = [
            ""
            ""
            ""
          ];
        };
        mpris = {
          format = "{player_icon}";
          format-paused = "{status_icon}";
          tooltip-format = "{player_icon} {dynamic}";
          tooltip-format-paused = "{status_icon} <i>{dynamic}</i>";
          player-icons = {
            default = "▶";
            mpv = "🎵";
          };
          status-icons = {
            paused = "⏸";
          };
        };
        gamemode = {
          format = "{glyph}";
          format-alt = "{glyph} {count}";
          glyph = "";
          hide-not-running = true;
          use-icon = true;
          icon-name = "input-gaming-symbolic";
          icon-spacing = 4;
          icon-size = 20;
          tooltip = true;
          tooltip-format = "Games running: {count}";
        };
        "custom/power" = {
          format = "󰐥";
          tooltip = false;
          on-click = "rofi -show power-menu -modi power-menu:rofi-power-menu";
        };
        "custom/os" = {
          format = "";
          on-click = "rofi -show drun";
          tooltip = false;
        };
        "custom/recorder" =
          let
            stop-screen-recorder = pkgs.writeShellScript "stop-screen-recorder" ''
              pid=`pgrep wl-screenrec`
              signal=$?

              if [ $signal == 0 ]; then
                pkill --signal SIGINT wl-screenrec
                dunstify "Stoped Screen recorder"
              fi;
            '';
          in
          {
            format = "";
            on-click = "${stop-screen-recorder}";
            return-type = "json";
            interval = 1;
            exec = "echo '{\"class\": \"recording\"}'";
            exec-if = "pgrep wl-screenrec";
          };
      };
    };
  };
}
