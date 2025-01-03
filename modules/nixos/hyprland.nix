{
  config,
  pkgs,
  username,
  inputs,
  ...
}: {
  # can't work with custom gnome module from ./gnome.nix
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "footclient";
  };

  environment.systemPackages = with pkgs; [
    loupe
    adwaita-icon-theme
    file-roller
    baobab
    nautilus
    nautilus-python
    gnome-calendar
    gnome-system-monitor
    gnome-control-center
    gnome-weather
    gnome-calculator
    gnome-clocks
    gnome-software # for flatpak
    wl-gammactl
    wl-clipboard
    wayshot
    pavucontrol
    brightnessctl
  ];

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
    pam.services.hyprlock = {};
    pam.services.ags = {};
  };
  services = {
    gvfs.enable = true;
    devmon.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    accounts-daemon.enable = true;
    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };

  services.greetd = {
    enable = true;
    settings.default_session.command = pkgs.writeShellScript "greeter" ''
      export XKB_DEFAULT_LAYOUT=${config.services.xserver.xkb.layout}
      ${pkgs.ags-greeter}/bin/greeter
    '';
  };

  systemd.tmpfiles.rules = [
    "d '/var/cache/greeter' - greeter greeter - -"
  ];

  system.activationScripts.wallpaper = let
    wp = pkgs.writeShellScript "wp" ''
      CACHE="/var/cache/greeter"
      OPTS="$CACHE/options.json"
      HOME="/home/$(find /home -maxdepth 1 -printf '%f\n' | tail -n 1)"

      mkdir -p "$CACHE"
      chown greeter:greeter $CACHE

      if [[ -f "$HOME/.cache/ags/options.json" ]]; then
        cp $HOME/.cache/ags/options.json $OPTS
        chown greeter:greeter $OPTS
      fi

      if [[ -f "$HOME/.config/background" ]]; then
        cp "$HOME/.config/background" $CACHE/background
        chown greeter:greeter "$CACHE/background"
      fi
    '';
  in
    builtins.readFile wp;
}
