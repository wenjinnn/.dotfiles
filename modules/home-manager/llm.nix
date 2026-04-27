{ pkgs, ... }:
{

  home.packages = with pkgs; [
    qwen-code
    mcp-nixos
    nur.repos.definfo.cc-switch-cli
    claude-agent-acp
  ];
  programs = {
    bash = {
      shellAliases = {
        # Alias to connect to the most recent nvim instance
        opencode = ''
          env NVIM_SOCKET_PATH=''${NVIM:-$( \
                  find "''${XDG_RUNTIME_DIR:-''${TMPDIR}nvim.''${USER}}/" -type s -name 'nvim.*.0' -printf '%T@ %p\n' 2>/dev/null \
                  | sort -nr \
                  | head -n 1 \
                  | awk '{print $2}')} \
          opencode
        '';
        gemini = ''
          env GEMINI_API_KEY="$(sops exec-env $SOPS_SECRETS 'echo -n $GEMINI_API_KEY')" \
          GOOGLE_CLOUD_PROJECT="$(sops exec-env $SOPS_SECRETS 'echo -n $GOOGLE_CLOUD_PROJECT')" \
          NVIM_SOCKET_PATH=''${NVIM:-$( \
                  find "''${XDG_RUNTIME_DIR:-''${TMPDIR}nvim.''${USER}}/" -type s -name 'nvim.*.0' -printf '%T@ %p\n' 2>/dev/null \
                  | sort -nr \
                  | head -n 1 \
                  | awk '{print $2}')} \
          gemini
        '';
      };
    };
    claude-code.enable = true;
    gemini-cli.enable = true;
    opencode.enable = true;
    codex.enable = true;
  };
}
