{username, ...}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      name = username;
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
