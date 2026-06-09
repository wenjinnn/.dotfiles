{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
let
  anthropic-skills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "da20c92503b2e8ff1cf28ca81a0df4673debdbf7";
    sha256 = "sha256-BiZvEV7VK1AwhiGg+pNMgTUQmt4exevLWwL0Brx4YyE=";
  };
  juliusbrussee-caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "655b7d9c5431f822264b7732e9901c5578ac84cf";
    sha256 = "sha256-BydREt/vai3j7kO5+e1OxsjXf6Vy+jSY1yA/yyxjHbI=";
  };
  obra-superpowers = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "6fd4507659784c351abbd2bc264c7162cfd386dc";
    sha256 = "sha256-P/FD8HTQO+QzvMe3A/B2v2vjs8T6ZmIYH3MPp79dSzo=";
  };
  xlsx = "${anthropic-skills}/skills/xlsx";
  docx = "${anthropic-skills}/skills/docx";
  pptx = "${anthropic-skills}/skills/pptx";
  pdf = "${anthropic-skills}/skills/pdf";
  doc-coauthoring = "${anthropic-skills}/skills/doc-coauthoring";
  skill-creator = "${anthropic-skills}/skills/skill-creator";
  # obra-superpowers has individual skills under skills/, not a single SKILL.md at root.
  # Enumerate them so each gets its own symlink in ~/.codex/skills/, ~/.claude/skills/, etc.
  superpowers-skills = lib.mapAttrs'
    (name: _: lib.nameValuePair "superpower-${name}" "${obra-superpowers}/skills/${name}")
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir "${obra-superpowers}/skills"));
  caveman-skill = "${juliusbrussee-caveman}/skills";
  claude-plugins-official = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "bd7cf41fc8a468b136a9266633303ff4a011c7b4";
    sha256 = "sha256-miC00qNR67rFSfRPulYkfUzfwXv0CeUkjhTGD6UXr+A=";
  };
  personnal-skill = ./skills;
in
{

  imports = with outputs.homeManagerModules; [
    pi
    oh-my-pi
  ];

  home.packages = with pkgs; [
    qwen-code
    mcp-nixos
    claude-agent-acp
    codex-acp
    pkgs.nur.repos.wenjinnn.pi-acp
  ];
  programs =
    let
      sops-exec-env = "${lib.getExe pkgs.sops} exec-env ${config.home.sessionVariables.SOPS_SECRETS}";
    in
    {
      bash = {
        shellAliases = {
          gemini = ''
            env GEMINI_API_KEY="$(sops exec-env $SOPS_SECRETS 'echo -n $GEMINI_API_KEY')" \
            GOOGLE_CLOUD_PROJECT="$(sops exec-env $SOPS_SECRETS 'echo -n $GOOGLE_CLOUD_PROJECT')" \
            gemini
          '';
        };
      };
      mcp = {
        enable = true;
        servers = {
          nixos = {
            enable = true;
            command = "mcp-nixos";
          };
        };
      };
      claude-code = {
        enable = true;
        enableMcpIntegration = true;
        marketplaces = {
          anthropic-skills = anthropic-skills;
          claude-plugins-official = claude-plugins-official;
          obra-superpowers = obra-superpowers;
          juliusbrussee-caveman = juliusbrussee-caveman;
        };
        settings = {
          # deepseek integration
          # apiKeyHelper = "${lib.getExe pkgs.sops} exec-env ${config.home.sessionVariables.SOPS_SECRETS} 'echo -n $DEEPSEEK_API_KEY'";
          # env = {
          #   ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic";
          #   ANTHROPIC_MODEL="deepseek-v4-pro[1m]";
          #   ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]";
          #   ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]";
          #   ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash";
          #   CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash";
          #   CLAUDE_CODE_EFFORT_LEVEL="max";
          # };
          apiKeyHelper = "${sops-exec-env} 'echo -n $MIMO_API_KEY'";
          env = {
            ANTHROPIC_BASE_URL = "https://token-plan-cn.xiaomimimo.com/anthropic";
            ANTHROPIC_DEFAULT_HAIKU_MODEL = "mimo-v2.5-pro";
            ANTHROPIC_DEFAULT_OPUS_MODEL = "mimo-v2.5-pro[1m]";
            ANTHROPIC_DEFAULT_SONNET_MODEL = "mimo-v2.5-pro[1m]";
            ANTHROPIC_MODEL = "mimo-v2.5-pro[1m]";
            ANTHROPIC_REASONING_MODEL = "mimo-v2-pro[1m]";
          };
          statusLine = {
            command = "jq -r '\"\\(.model.display_name) | \\(.context_window.used_percentage // 0)% context | \\(.context_window.current_usage.input_tokens // 0) 📥 \\(.context_window.current_usage.output_tokens // 0) 📤 \\(.context_window.current_usage.cache_creation_input_tokens // 0) ✏️ \\(.context_window.current_usage.cache_read_input_tokens // 0) 📖 token | $\\((.cost.total_cost_usd // 0) | .*100 | round / 100) | 📁 \\(.workspace.current_dir) \"'";
            padding = 0;
            type = "command";
          };
          enabledPlugins = {
            "document-skills@anthropic-skills" = true;
            "skill-creator@claude-plugins-official" = true;
            "superpowers@obra-superpowers" = true;
            "caveman@juliusbrussee-caveman" = true;
          };
        };
      };
      codex = {
        enable = true;
        enableMcpIntegration = true;
        settings = {
          model_provider = "openrouter";
          model = "deepseek/deepseek-v4-pro";
          model_reasoning_effort = "high";

          model_providers = {
            openrouter = {
              auth = {
                command = "bash";
                args = [
                  "-c"
                  "${sops-exec-env} 'echo -n $OPENROUTER_API_KEY'"
                ];
              };
              name = "openrouter";
              base_url = "https://openrouter.ai/api/v1";
            };
          };
          tui.status_line = [
            "model-with-reasoning"
            "context-used"
            "total-input-tokens"
            "total-output-tokens"
            "current-dir"
            "git-branch"
            "branch-changes"
          ];
        };
        skills = {
          inherit
            doc-coauthoring
            skill-creator
            xlsx
            docx
            pptx
            pdf
            caveman-skill
            ;
        } // superpowers-skills;
      };
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        settings = {
          autoupdate = false;
          provider = {
            deepseek = {
              options = {
                apiKey = "{file:${config.sops.secrets.DEEPSEEK_API_KEY.path}}";
              };
            };
            xiaomi-token-plan-cn = {
              options = {
                apiKey = "{file:${config.sops.secrets.MIMO_API_KEY.path}}";
              };
            };
            google = {
              options = {
                apiKey = "{file:${config.sops.secrets.GEMINI_API_KEY.path}}";
              };
            };
            openrouter = {
              options = {
                apiKey = "{file:${config.sops.secrets.OPENROUTER_API_KEY.path}}";
              };
            };
          };
        };
        skills = {
          inherit
            doc-coauthoring
            skill-creator
            xlsx
            docx
            pptx
            pdf
            caveman-skill
            ;
        } // superpowers-skills;
      };
      gemini-cli = {
        enable = true;
        enableMcpIntegration = true;
      };
      pi = {
        enable = true;
        auth = {
          xiaomi-token-plan-cn = {
            type = "api_key";
            key = "!${sops-exec-env} 'echo -n $MIMO_API_KEY'";
          };
          deepseek = {
            type = "api_key";
            key = "!${sops-exec-env} 'echo -n $DEEPSEEK_API_KEY'";
          };
          google = {
            type = "api_key";
            key = "!${sops-exec-env} 'echo -n $GEMINI_API_KEY'";
          };
          openrouter = {
            type = "api_key";
            key = "!${sops-exec-env} 'echo -n $OPENROUTER_API_KEY'";
          };
        };
        extraPackages = [
          pkgs.nur.repos.wenjinnn.piPackages."@gotgenes/pi-subagents"
          pkgs.nur.repos.wenjinnn.piPackages."@gotgenes/pi-permission-system"
          pkgs.nur.repos.wenjinnn.piPackages."@tmustier/pi-usage-extension"
          pkgs.nur.repos.wenjinnn.piPackages."@juicesharp/rpiv-ask-user-question"
          pkgs.nur.repos.wenjinnn.piPackages."@juicesharp/rpiv-btw"
          pkgs.nur.repos.wenjinnn.piPackages."@llblab/pi-telegram"
          pkgs.nur.repos.wenjinnn.piPackages."@wenjinnn/pi-mimo-voice"
          pkgs.nur.repos.wenjinnn.piPackages."pi-lens"
          pkgs.nur.repos.wenjinnn.piPackages."pi-mcp-adapter"
          pkgs.nur.repos.wenjinnn.piPackages."pi-web-access"
          pkgs.nur.repos.wenjinnn.piPackages."pi-hermes-memory"
          pkgs.nur.repos.wenjinnn.piPackages."context-mode"
        ];
        settings = {
          defaultProvider = "xiaomi-token-plan-cn";
          defaultModel = "mimo-v2.5-pro";
          defaultThinkingLevel = "high";
          # quietStartup = true;
          theme = "dark";
          enableInstallTelemetry = false;
          skills = [
            doc-coauthoring
            skill-creator
            xlsx
            docx
            pptx
            pdf
            personnal-skill
          ] ++ (lib.attrValues superpowers-skills);
        };
        keybindings = {
          "tui.select.up" = [
            "up"
            "ctrl+p"
          ];
          "tui.select.down" = [
            "down"
            "ctrl+n"
          ];
          "app.model.cycleForward" = [ "ctrl+alt+p" ];
        };
      };
      oh-my-pi = {
        enable = true;
        settings = {
          modelRoles = {
            default = "xiaomi/mimo-v2.5-pro";
            smol = "xiaomi/mimo-v2.5-pro";
            slow = "xiaomi/mimo-v2.5-pro";
            plan = "xiaomi/mimo-v2.5-pro";
            commit = "xiaomi/mimo-v2.5-pro";
          };
          theme.dark = "titanium";
          display.showTokenUsage = true;
          startup.checkUpdate = false;
          marketplace.autoUpdate = "off";
          symbolPreset = "unicode";
          memory.backend = "local";
          # startup.quiet = true;
          startup.setupWizard = false;
        };
        # API keys via sops — injected at launch time
        preLaunchHook = ''
          export XIAOMI_API_KEY="$(${sops-exec-env} 'echo -n $MIMO_API_KEY')"
          export DEEPSEEK_API_KEY="$(${sops-exec-env} 'echo -n $DEEPSEEK_API_KEY')"
          export GEMINI_API_KEY="$(${sops-exec-env} 'echo -n $GEMINI_API_KEY')"
          export OPENROUTER_API_KEY="$(${sops-exec-env} 'echo -n $OPENROUTER_API_KEY')"
        '';
        keybindings = {
          "tui.select.up" = "ctrl+p";
          "tui.select.down" = "ctrl+n";
          "app.model.cycleForward" = "ctrl+alt+p";
        };
      };
    };
}
