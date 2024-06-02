{pkgs, ...}: {
  home.packages = with pkgs; [
    adw-gtk3
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

# home.sessionVariables = {
#   GTK_THEME = "Adwaita-dark";
# };

  services = {
    xsettingsd = {
      enable = true;
      settings = {
        "Gdk/UnscaledDPI" = 98304;
        "Gdk/WindowScalingFactor" = 2;
      };
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Adwaita";
    size = 24;
  };
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "Sans 11";
      monospace-font-name = "Monospace 10";
      document-font-name = "Sans 11";
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Sans Bold 11";
    };
  };
  qt = {
    enable = true;
    style = {
      package = with pkgs; [
        adwaita-qt
        adwaita-qt6
      ];
      name = "adwaita-dark";
    };
    platformTheme.name = "gtk";
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.unstable.morewaita-icon-theme;
      name = "MoreWaita";
    };
  };

  home.file = {
    ".config/qt5ct/qt5ct.conf".text = ''
      [Appearance]
      color_scheme_path=${pkgs.qt5ct}/share/qt5ct/colors/airy.conf
      custom_palette=false
      standard_dialogs=xdgdesktopportal
      style=Adwaita-Dark

      [Fonts]
      fixed="Sans Serif,12,-1,5,50,0,0,0,0,0"
      general="Sans Serif,12,-1,5,50,0,0,0,0,0"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3

      [SettingsWindow]
      geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x3\x9f\0\0\x4`\0\0\0\0\0\0\0\0\0\0\x3>\0\0\x3\x1d\0\0\0\0\x2\0\0\0\a\x80\0\0\0\0\0\0\0\0\0\0\x3\x9f\0\0\x4`)

      [Troubleshooting]
      force_raster_widgets=1
      ignored_applications=@Invalid()
    '';
    ".config/qt6ct/qt6ct.conf".text = ''
      [Appearance]
      color_scheme_path=${pkgs.qt6ct}/share/qt6ct/colors/airy.conf
      custom_palette=false
      standard_dialogs=xdgdesktopportal
      style=Adwaita-Dark

      [Fonts]
      fixed="Sans Serif,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
      general="Sans Serif,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3

      [SettingsWindow]
      geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x3\x9f\0\0\x4`\0\0\0\0\0\0\0\0\0\0\x3\x41\0\0\x2\xe7\0\0\0\0\x2\0\0\0\a\x80\0\0\0\0\0\0\0\0\0\0\x3\x9f\0\0\x4`)

      [Troubleshooting]
      force_raster_widgets=1
      ignored_applications=@Invalid()
    '';
  };
}
