{me, ...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      name = me.username;
      isDefault = true;
      search = {
        default = "DuckDuckGo";
        order = [
          "DuckDuckGo"
          "Bing"
          "Google"
        ];
      };
    };
  };
}
