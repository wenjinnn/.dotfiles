{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "gruvbox";
      mcp = {
        context7 = {
          enabled = true;
          type = "local";
          command = [
            "npx"
            "-y"
            "@upstash/context7-mcp"
          ];
        };
        neovim = {
          enabled = true;
          type = "local";
          command = [
            "npx"
            "-y"
            "mcp-neovim-server"
          ];
          environment = {
            ALLOW_SHELL_COMMANDS = true;
            NVIM_SOCKET_PATH = "/tmp/nvim";
          };
        };
      };
    };
  };
}
