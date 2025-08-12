{
  programs.opencode = {
    enable = true;
    settings = {
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
