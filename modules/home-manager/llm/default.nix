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
  # Copy a skill dir and add `disable-model-invocation: true` to its SKILL.md
  # frontmatter: the skill stays out of the system prompt (model won't
  # auto-trigger it) but remains invocable via /skill:name.
  # Idempotent: many upstream skills already declare the flag — skip those.
  slashOnlySkill =
    skillDir:
    pkgs.runCommand "slash-only-${builtins.baseNameOf skillDir}" { } ''
      mkdir -p $out
      cp -r ${skillDir}/. $out/
      chmod +w $out/SKILL.md
      # only insert when the frontmatter doesn't already have it
      if ! grep -q '^disable-model-invocation:' $out/SKILL.md; then
        sed -i '2i disable-model-invocation: true' $out/SKILL.md
      fi
    '';
  # mattpocock skills we keep auto-invocable (realtime), the rest go slash-only.
  # ask-matt/implement are already disable-model-invocation upstream — whether
  # listed here or not they stay slash-only, so they're omitted for clarity.
  mattRealtime = [
    "code-review"
    "diagnosing-bugs"
    "research"
    "tdd"
    "resolving-merge-conflicts"
  ];
  # mattpocock skills the upstream repo marks as deprecated: drop entirely
  mattDeprecated = [
    "design-an-interface"
    "qa"
    "request-refactor-plan"
    "ubiquitous-language"
  ];
  mattName = key: lib.strings.removePrefix "matt-" key;
  mattpocock-adjusted = lib.mapAttrs (
    key: dir: if lib.elem (mattName key) mattRealtime then dir else slashOnlySkill dir
  ) (lib.filterAttrs (key: _: !(lib.elem (mattName key) mattDeprecated)) mattpocock-skills);
  # ponytail core stays realtime; audit/debt/gain/help/review go slash-only
  ponytail-adjusted = lib.mapAttrs (
    key: dir: if key == "ponytail-ponytail" then dir else slashOnlySkill dir
  ) ponytail-skills;
in
{

  imports = with outputs.homeManagerModules; [
    oh-my-pi
    pi-plugins
    pi-theme
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
        # pi-lens launches the Java LSP server via $JDTLS_PATH and reads the
        # lombok jar from $PI_LENS_LOMBOK_JAR. Inject both only into pi's own
        # process environment (not the global shell env) by wrapping the pi
        # binary: JDTLS_PATH -> jdtls-pi-lens wrapper (no metadata files at
        # project root, shares nvim's jdtls cache, see pkgs/jdtls-pi-lens),
        # PI_LENS_LOMBOK_JAR -> the nixpkgs lombok jar used by nvim too.
        package = pkgs.writeShellScriptBin "pi" ''
          export JDTLS_PATH="${pkgs.jdtls-pi-lens}/bin/jdtls-pi-lens"
          export PI_LENS_LOMBOK_JAR="${pkgs.lombok}/share/java/lombok.jar"
          export TELEGRAM_BOT_TOKEN="$(${sops-exec-env} 'echo -n $TELEGRAM_BOT_TOKEN')"
          exec "${pkgs.llm-agents.pi}/bin/pi" "$@"
        '';
        extraPackages = [
          pkgs.nodejs
          pkgs.bun
        ];
        context = ./pi-context.md;
        # this option came form modules/home-manager/pi-plugins.nix
        agents = {
          # Custom pi-subagents agents → ~/.pi/agent/agents/
          "vision" = {
            source = ./agents/vision.md;
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
              worker = {
                model = "openai-codex/gpt-5.6-terra";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-flash" ];
              };
              reviewer = {
                model = "openai-codex/gpt-5.6-terra";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-flash" ];
              };
            };
          };
          # theme = "stylix" is owned by modules/home-manager/pi-theme.nix
          # (generates ~/.pi/agent/themes/stylix.json from the stylix palette).
          # Don't set a plain `theme` here or the two definitions collide;
          # disable via `programs.pi-coding-agent.stylixTheme = false`.
          enableInstallTelemetry = false;
          packages = [
            "npm:pi-lens"
            "npm:pi-intercom"
            "npm:pi-subagents"
            "npm:pi-mcp-adapter"
            "npm:pi-web-access"
            "npm:pi-hermes-memory"
            "npm:context-mode"
            "npm:pi-goal-list-loop-audit"
            "npm:@narumitw/pi-usage"
            "npm:@gotgenes/pi-permission-system"
            "npm:@juicesharp/rpiv-todo"
            "npm:@llblab/pi-telegram"
          ];
          skills = [
            # anthropic file-format skills: slash-only (long descriptions,
            # only needed when actually touching such files)
            (slashOnlySkill doc-coauthoring)
            (slashOnlySkill xlsx)
            (slashOnlySkill docx)
            (slashOnlySkill pptx)
            (slashOnlySkill pdf)
            # ./skills: nix-first stays realtime, nix-packing already
            # declares disable-model-invocation in its own frontmatter
            personnal-skill
          ]
          # ++ (lib.attrValues superpowers-skills)
          ++ (lib.attrValues ponytail-adjusted)
          ++ (lib.attrValues mattpocock-adjusted);
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
          "pi-permission-system" = {
            # Danger-command guardrail only: everything is allowed by
            # default; only destructive/privileged commands prompt or
            # are blocked. Requires yoloMode = false (yoloMode auto-
            # approves every ask-state check, i.e. no protection at all).
            # Semantics (docs/configuration.md): each command in a chain
            # is matched independently, most restrictive wins
            # (deny > ask > allow), last matching pattern wins.
            config = {
              yoloMode = false;
              debugLog = false;
              permissionReviewLog = true;
              permission = {
                # Universal fallback: allow every tool by default.
                "*" = "allow";
                bash = {
                  # Catch-all first; specific rules below override it.
                  "*" = "allow";
                  # deny — filesystem-level destruction an agent has no
                  # legitimate reason to run.
                  "mkfs*" = {
                    action = "deny";
                    reason = "Formatting a filesystem is destructive and irreversible";
                  };
                  "fdisk *" = {
                    action = "deny";
                    reason = "Disk partitioning is destructive and irreversible";
                  };
                  "parted *" = {
                    action = "deny";
                    reason = "Disk partitioning is destructive and irreversible";
                  };
                  "shred *" = {
                    action = "deny";
                    reason = "Secure erase is destructive and irreversible";
                  };
                  # ask — dangerous but sometimes legitimate; confirm first.
                  "rm -rf *" = "ask";
                  "rm -fr *" = "ask";
                  "git clean -f*" = "ask";
                  "git reset --hard *" = "ask";
                  "ssh *" = "ask";
                  "sudo *" = "ask";
                  "git push *" = "ask";
                  "npm publish *" = "ask";
                  "shutdown *" = "ask";
                  "reboot *" = "ask";
                  "poweroff *" = "ask";
                  "dd *" = "ask";
                };
              };
            };
          };
        };
        keybindings = {
          "tui.editor.cursorUp" = [
            "up"
            "ctrl+p"
          ];
          "tui.editor.cursorDown" = [
            "down"
            "ctrl+n"
          ];
          "tui.editor.cursorLeft" = [
            "left"
            "ctrl+b"
          ];
          "tui.editor.cursorRight" = [
            "right"
            "ctrl+f"
          ];
          "tui.select.up" = [
            "up"
            "ctrl+p"
          ];
          "tui.select.down" = [
            "down"
            "ctrl+n"
          ];
          "app.model.cycleForward" = [ "ctrl+alt+p" ];
          # C-n is occupied by tui.select.down, naming filter moved to Ctrl+Shift+N
          "app.session.toggleNamedFilter" = [ "ctrl+shift+n" ];
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
