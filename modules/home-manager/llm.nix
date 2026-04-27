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
        gemini = ''
          env GEMINI_API_KEY="$(sops exec-env $SOPS_SECRETS 'echo -n $GEMINI_API_KEY')" \
          GOOGLE_CLOUD_PROJECT="$(sops exec-env $SOPS_SECRETS 'echo -n $GOOGLE_CLOUD_PROJECT')" \
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
