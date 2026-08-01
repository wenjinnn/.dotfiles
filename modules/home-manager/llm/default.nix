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
    rev = "fa0fa64bdc967915dc8399e803be67759e1e62b8";
    sha256 = "sha256-QZ+zJkyLd/42rxgtJEZSUOz9R75Tse6UXW7G0nOkFS8=";
  };
  juliusbrussee-caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "0d95a81d35a9f2d123a5e9430d1cfc43d55f1bb0";
    sha256 = "sha256-VqRHx3/4SSCnEh3cUJ/he5saIfwNhS0hOzoH/wwtU2o=";
  };
  obra-superpowers = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "d884ae04edebef577e82ff7c4e143debd0bbec99";
    sha256 = "sha256-kHdQ9e44doBk2yYW88tMSCqVG8ycYcvJSZlrIziXhpA=";
  };
  mattpocock-skills-src = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "9603c1cc8118d08bc1b3bf34cf714f62178dea3b";
    sha256 = "sha256-S6pARK99oGGSi6XdFm6zYKHT4gjOCN0wIPZFcl1hREE=";
  };
  dietrichgebert-ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "16f29800fd2681bdf24f3eb4ccffe38be3baec6b";
    sha256 = "sha256-Y7d4s7uqjH6IbEXhqAiQ+yaxr6iiGcv2X64LuMtG1T8=";
  };
  xlsx = "${anthropic-skills}/skills/xlsx";
  docx = "${anthropic-skills}/skills/docx";
  pptx = "${anthropic-skills}/skills/pptx";
  pdf = "${anthropic-skills}/skills/pdf";
  doc-coauthoring = "${anthropic-skills}/skills/doc-coauthoring";
  skill-creator = "${anthropic-skills}/skills/skill-creator";
  # obra-superpowers has individual skills under skills/, not a single SKILL.md at root.
  # Enumerate them so each gets its own symlink in ~/.codex/skills/, ~/.claude/skills/, etc.
  superpowers-skills = lib.mapAttrs' (
    name: _: lib.nameValuePair "superpower-${name}" "${obra-superpowers}/skills/${name}"
  ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir "${obra-superpowers}/skills"));
  ponytail-skills =
    lib.mapAttrs'
      (name: _: lib.nameValuePair "ponytail-${name}" "${dietrichgebert-ponytail}/skills/${name}")
      (
        lib.filterAttrs (_: type: type == "directory") (
          builtins.readDir "${dietrichgebert-ponytail}/skills"
        )
      );
  caveman-skill = "${juliusbrussee-caveman}/skills";
  # Enumerate mattpocock skills from all categories
  mattpocock-skills = lib.concatMapAttrs (
    category: _:
    let
      categoryDir = "${mattpocock-skills-src}/skills/${category}";
    in
    if builtins.pathExists categoryDir then
      lib.mapAttrs' (name: _: lib.nameValuePair "matt-${name}" "${categoryDir}/${name}") (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir categoryDir)
      )
    else
      { }
  ) (builtins.readDir "${mattpocock-skills-src}/skills");
  claude-plugins-official = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "9ddfad2e999789e0220cacaf359b64dd873e7d72";
    sha256 = "sha256-jlo28awHcmoNN42tmit0Mif9WyrkC2OmjJgRDlLpVCo=";
  };
  personnal-skill = ./skills;
in
{

  imports = with outputs.homeManagerModules; [
    oh-my-pi
    pi-plugins
  ];

  home.packages = with pkgs; [
    qwen-code
    mcp-nixos
    claude-agent-acp
    codex-acp
    pi-acp
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
        package = pkgs.llm-agents.claude-code;
        enableMcpIntegration = true;
        marketplaces = {
          anthropic-skills = anthropic-skills;
          claude-plugins-official = claude-plugins-official;
          obra-superpowers = obra-superpowers;
          juliusbrussee-caveman = juliusbrussee-caveman;
          dietrichgebert-ponytail = dietrichgebert-ponytail;
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
            "ponytail@dietrichgebert-ponytail" = true;
          };
        };
      };
      codex = {
        enable = true;
        package = pkgs.llm-agents.codex;
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
        }
        # // superpowers-skills
        // ponytail-skills
        // mattpocock-skills;
      };
      opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
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
        }
        # // superpowers-skills
        // ponytail-skills;
      };
      antigravity-cli = {
        enable = true;
        package = pkgs.llm-agents.gemini-cli;
        enableMcpIntegration = true;
      };
      pi-coding-agent = {
        enable = true;
        package = pkgs.llm-agents.pi;
        agents = {
          # Custom pi-subagents agents → ~/.pi/agent/agents/
          "vision-reader" = {
            source = ./agents/vision-reader.md;
          };
        };
        models = {
          providers = {
            xiaomi-token-plan-cn = {
              apiKey = "!${sops-exec-env} 'echo -n $MIMO_API_KEY'";
            };
            deepseek = {
              apiKey = "!${sops-exec-env} 'echo -n $DEEPSEEK_API_KEY'";
            };
            google = {
              apiKey = "!${sops-exec-env} 'echo -n $GEMINI_API_KEY'";
            };
            openrouter = {
              apiKey = "!${sops-exec-env} 'echo -n $OPENROUTER_API_KEY'";
            };
          };
        };
        settings = {
          defaultProvider = "deepseek";
          defaultModel = "deepseek-v4-flash";
          defaultThinkingLevel = "high";
          quietStartup = true;
          subagents = {
            agentOverrides = {
              oracle = {
                model = "openai-codex/gpt-5.6-sol";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-pro" ];
              };
              planner = {
                model = "openai-codex/gpt-5.6-sol";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-pro" ];
              };
              researcher = {
                model = "openai-codex/gpt-5.6-sol";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-pro" ];
              };
            };
          };
          theme = "dark";
          enableInstallTelemetry = false;
          packages = [
            "npm:pi-subagents"
            "npm:@juicesharp/rpiv-ask-user-question"
            "npm:@juicesharp/rpiv-todo"
            "npm:@juicesharp/rpiv-btw"
            "npm:@llblab/pi-telegram"
            "npm:pi-goal-list-loop-audit"
            "npm:pi-lens"
            "npm:pi-mcp-adapter"
            "npm:pi-web-access"
            "npm:pi-hermes-memory"
            "npm:context-mode"
            "npm:@tmustier/pi-usage-extension"
          ];
          skills = [
            doc-coauthoring
            xlsx
            docx
            pptx
            pdf
            personnal-skill
          ]
          # ++ (lib.attrValues superpowers-skills)
          ++ (lib.attrValues ponytail-skills)
          ++ (lib.attrValues mattpocock-skills);
        };
        # Declarative config for individual plugins (pi-web-access, ...).
        # Managed via modules/home-manager/pi-plugins.nix.
        # Config lands at $XDG_CONFIG_HOME/pi/web-search.json (copy mode:
        # re-synced on every rebuild, stays writable between rebuilds).
        plugins = {
          "pi-web-access" = {
            config = {
              workflow = "auto-summary";
            };
          };
          "pi-goal-list-loop-audit" = {
            # Global settings file — NOT the conventional
            # extensions/<name>/config.json: goal-settings.ts hardcodes
            # ~/.pi/agent/pi-goal-list-loop-audit.settings.json.
            # copy mode keeps it writable for /glla runtime edits, and
            # every rebuild re-syncs the declared values (same trade-off
            # as pi-web-access).
            path = "${config.home.homeDirectory}/.pi/agent/pi-goal-list-loop-audit.settings.json";
            config = {
              auditorModel = "deepseek/deepseek-v4-pro";
            };
          };
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
        package = pkgs.llm-agents.omp;
        settings = {
          modelRoles = {
            default = "xiaomi/mimo-v2.5-pro";
            smol = "openai-codex/gpt-5.6-luna";
            slow = "openai-codex/gpt-5.6-sol";
            plan = "openai-codex/gpt-5.6-terra";
            vision = "xiaomi/mimo-v2.5";
            designer = "openai-codex/gpt-5.6-terra";
            commit = "xiaomi/mimo-v2.5-pro";
            task = "openai-codex/gpt-5.6-terra";
            tiny = "xiaomi/mimo-v2.5";
            advisor = "openai-codex/gpt-5.6-sol";
          };
          providers.webSearch = "exa";
          theme.dark = "dark-gruvbox";
          display.showTokenUsage = true;
          startup.checkUpdate = false;
          marketplace.autoUpdate = "off";
          symbolPreset = "unicode";
          memory.backend = "local";
          autolearn.enabled = true;
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
          "tui.select.up" = [
            "up"
            "ctrl+p"
          ];
          "tui.select.down" = [
            "down"
            "ctrl+n"
          ];
          "app.model.cycleForward" = "ctrl+alt+p";
        };
        skills = [
          doc-coauthoring
          skill-creator
          xlsx
          docx
          pptx
          pdf
          personnal-skill
        ]
        # ++ (lib.attrValues superpowers-skills)
        ++ (lib.attrValues ponytail-skills)
        ++ (lib.attrValues mattpocock-skills);
      };
    };
}
