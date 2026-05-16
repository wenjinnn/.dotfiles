{ pkgs, ... }:
let
  anthropic-skills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "f458cee31a7577a47ba0c9a101976fa599385174";
    sha256 = "sha256-jKNYFom6R+Qw7LQ8vFPBe51JpqIP0tTSY8LM4aPlnT4=";
  };
  obra-superpowers = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.1.0";
    sha256 = "sha256-3E3rO6hR87JUfS3XV1Eaoz6SDWOftleWvN9UPNFEMjw=";
  };
  xlsx = "${anthropic-skills}/skills/xlsx";
  docx = "${anthropic-skills}/skills/docx";
  pptx = "${anthropic-skills}/skills/pptx";
  pdf = "${anthropic-skills}/skills/pdf";
  doc-coauthoring = "${anthropic-skills}/skills/doc-coauthoring";
  skill-creator = "${anthropic-skills}/skills/skill-creator";
  superpower = "${obra-superpowers}/skills";
in
{

  home.packages = with pkgs; [
    qwen-code
    mcp-nixos
    claude-agent-acp
    codex-acp
  ];
  programs = {
    bash = {
      shellAliases = {
        gemini = ''
          env GEMINI_API_KEY="$(sops exec-env $SOPS_SECRETS 'echo -n $GEMINI_API_KEY')" \
          GOOGLE_CLOUD_PROJECT="$(sops exec-env $SOPS_SECRETS 'echo -n $GOOGLE_CLOUD_PROJECT')" \
          gemini
        '';
        claude = ''
          env \
          ANTHROPIC_AUTH_TOKEN="$(sops exec-env $SOPS_SECRETS 'echo -n $MIMO_API_KEY')" \
          ANTHROPIC_BASE_URL="https://token-plan-cn.xiaomimimo.com/anthropic" \
          ANTHROPIC_DEFAULT_HAIKU_MODEL="mimo-v2.5-pro" \
          ANTHROPIC_DEFAULT_OPUS_MODEL="mimo-v2.5-pro" \
          ANTHROPIC_DEFAULT_SONNET_MODEL="mimo-v2.5-pro" \
          ANTHROPIC_MODEL="mimo-v2.5-pro" \
          ANTHROPIC_REASONING_MODEL="mimo-v2-pro" \
          claude
        '';
        codex = ''
          env \
          OPENAI_API_KEY="$(sops exec-env $SOPS_SECRETS 'echo -n $OPENROUTER_API_KEY')" \
          claude
        '';
      };
    };
    claude-code = {
      enable = true;
      enableMcpIntegration = true;
      marketplaces = {
        anthropic-skills = anthropic-skills;
        obra-superpowers = obra-superpowers;
      };
      plugins = [
        doc-coauthoring
        skill-creator
        xlsx
        docx
        pptx
        pdf
        obra-superpowers
      ];
      settings = {
        statusLine = {
          command = "jq -r '\"\\(.model.display_name)[\\(.context_window.context_window_size)] | \\(.context_window.used_percentage // 0)% context | \\(.context_window.current_usage.input_tokens // 0) 📥 \\(.context_window.current_usage.output_tokens // 0) 📤 \\(.context_window.current_usage.cache_creation_input_tokens // 0) ✏️ \\(.context_window.current_usage.cache_read_input_tokens // 0) 📖 token | $\\((.cost.total_cost_usd // 0) | .*100 | round / 100) | 📁 \\(.workspace.current_dir) \"'";
          padding = 0;
          type = "command";
        };
      };
    };
    codex = {
      enable = true;
      settings = {
        model_provider = "openrouter";
        model = "deepseek/deepseek-v4-pro";
        model_reasoning_effort = "high";
        disable_response_storage = true;

        model_providers = {
          openrouter = {
            name = "openrouter";
            base_url = "https://openrouter.ai/api/v1";
            wire_api = "responses";
            requires_openai_auth = true;
          };
        };

      };
      skills = {
        inherit
          superpower
          doc-coauthoring
          skill-creator
          xlsx
          docx
          pptx
          pdf
          ;
      };
    };
    gemini-cli.enable = true;
    opencode.enable = true;
  };
}
