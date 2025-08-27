{
  home.sessionVariables = {
    # Get the newest nvim socket to use it with opencode neovim mcp server
    NVIM_SOCKET_PATH = "$(find \"\${XDG_RUNTIME_DIR:-\${TMPDIR}nvim.\${USER}}/\" -type s -name 'nvim.*.0' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | awk '{print $2}')";
  };

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
        };
      };
    };
  };
}
