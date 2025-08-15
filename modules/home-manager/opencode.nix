{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "gruvbox";
      mcp = {
        context7 = {
          type = "local";
          command = [
            "npx"
            "-y"
            "@upstash/context7-mcp"
          ];
          enabled = true;
        };
      };
    };
  };
}
