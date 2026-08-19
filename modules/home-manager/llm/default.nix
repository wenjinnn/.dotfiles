{
  pkgs,
  lib,
  config,
  inputs,
  outputs,
  ...
}:
let
  anthropic-skills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "f17010c9bb483898c1d9c9f42dde2b3a98889434";
    sha256 = "sha256-vTqAu8eRY+8ymbf065SWHHjNX/li3SOR+sWq1npteTM=";
  };
  juliusbrussee-caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "11ddc0c9813c8f75365cd5be2f753df08712f154";
    sha256 = "sha256-54NN2TsYVVjWXJn6C+tPgCn1IdpecASJXeaMRpWXcFk=";
  };
  obra-superpowers = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "44c9b2d6e889982ac18c27d05a19fefe335194e1";
    sha256 = "sha256-fnl+HbPL2qD5Zgz8a1NctjFJSqu6UsyHJAhQMLQNXXc=";
  };
  mattpocock-skills-src = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "84fdeffd12f2ee307994d1eb6feb48173b6e0502";
    sha256 = "sha256-pseSJJb5nBBGPzpxA1GzjGLB9OrT+u0At1saJ4NqZ1E=";
  };
  dietrichgebert-ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "2ed6c52c9d7e5e56942508591085fd45dea277d3";
    sha256 = "sha256-bGdXvzhWPwGdz3T2Yh2h6lf+3PBRFAfdBxP5pESmCHI=";
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
    rev = "3da105324a27aa7b1f435a3925f8626092891d4e";
    sha256 = "sha256-OMA5XkdwpIL28OqoXMr/hB80E22gxRIf4lWwUHDI5ts=";
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
  # Matt Pocock skills the upstream repo marks as deprecated: drop entirely
  mattDeprecated = [
    "design-an-interface"
    "qa"
    "request-refactor-plan"
    "ubiquitous-language"
  ];
  # Experimental and non-current-development skills: keep out of Pi entirely.
  mattExcluded = [
    "ask-matt"
    "claude-handoff"
    "setup-ts-deep-modules"
    "writing-beats"
    "writing-fragments"
    "writing-shape"
    "git-guardrails-claude-code"
    "migrate-to-shoehorn"
    "scaffold-exercises"
    "setup-pre-commit"
  ];
  mattName = key: lib.strings.removePrefix "matt-" key;
  mattpocock-adjusted =
    lib.mapAttrs (key: dir: if lib.elem (mattName key) mattRealtime then dir else slashOnlySkill dir)
      (
        lib.filterAttrs (
          key: _: !(lib.elem (mattName key) (mattDeprecated ++ mattExcluded))
        ) mattpocock-skills
      );
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
    pi-web
  ];

  # pi-yaml-hooks has no setting for hiding loader advisories. Keep explicit
  # custom-tool events, but suppress only this informational UI entry.
  home.activation.piYamlHooksAdvisories = lib.hm.dag.entryAfter [ "installPackages" ] ''
    hook_dir="${config.home.homeDirectory}/.pi/agent/npm/node_modules/pi-yaml-hooks"
    for hook_js in "$hook_dir/src/pi/runtime-registry.ts" "$hook_dir/dist/pi/runtime-registry.js"; do
      [ -f "$hook_js" ] || continue
      # Pi loads the package's TypeScript entrypoint; patch both source and
      # dist because npm/package updates may switch the loaded representation.
      sed -i \
        -e 's/process.env.PI_YAML_HOOKS_SHOW_ADVISORIES !== 0/process.env.PI_YAML_HOOKS_SHOW_ADVISORIES !== "0"/' \
        -e 's/if (loaded.advisories.length > 0) {/if (process.env.PI_YAML_HOOKS_SHOW_ADVISORIES !== "0" \&\& loaded.advisories.length > 0) {/' \
        -e 's/console.info(summary);/if (process.env.PI_YAML_HOOKS_SHOW_LOAD_SUMMARY !== "0") console.info(summary);/' \
        "$hook_js"
    done
  '';

  home.packages = with pkgs; [
    qwen-code
    mcp-nixos
    claude-agent-acp
    codex-acp
    pi-acp
    qmd
  ];

  services.pi-web.enable = true;

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
        enable = false;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
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
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;
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
        enable = false;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
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
        enable = false;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.gemini-cli;
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
          export PI_YAML_HOOKS_SHOW_ADVISORIES=0
          export PI_YAML_HOOKS_SHOW_LOAD_SUMMARY=0

          exec "${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi}/bin/pi" "$@"
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
          defaultProvider = "openai-codex";
          defaultModel = "gpt-5.6-luna";
          defaultThinkingLevel = "high";
          # quietStartup = true;
          subagents = {
            agentOverrides = {
              oracle = {
                model = "openai-codex/gpt-5.6-terra";
                thinking = "xhigh";
                fallbackModels = [ "deepseek/deepseek-v4-pro" ];
              };
              researcher = {
                model = "openai-codex/gpt-5.6-terra";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-pro" ];
              };
              worker = {
                model = "openai-codex/gpt-5.6-terra";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-pro" ];
              };
              reviewer = {
                model = "openai-codex/gpt-5.6-terra";
                thinking = "high";
                fallbackModels = [ "deepseek/deepseek-v4-pro" ];
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
            # must load BEFORE pi-permission-system: pi runs tool_call handlers
            # sequentially, and the permission gate awaits its dialog inside its
            # own handler — hooks registered later fire after the prompt resolves.
            "npm:pi-yaml-hooks"
            "npm:pi-intercom"
            "npm:pi-subagents"
            "npm:pi-mcp-adapter"
            "npm:pi-web-access"
            "npm:context-mode"
            "npm:pi-memory"
            "npm:@narumitw/pi-goal"
            "npm:@tmustier/pi-ralph-wiggum"
            "npm:@narumitw/pi-usage"
            "npm:@gotgenes/pi-permission-system"
            # Model-reviewed auto-permission: registers the "pi-auto-review"
            # authorizer chain link (codex-auto-review model) into
            # pi-permission-system's authorizerChain. Actively maintained
            # against pi 0.83 + pps v24 (this repo's stack).
            "npm:@erichll/pi-auto-review"
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
              # Model-reviewed auto-permission (Codex-style): when a
              # permission check lands on "ask", the pi-auto-review authorizer
              # link (from @erichll/pi-auto-review) consults the
              # codex-auto-review model first; only a non-defer verdict skips
              # the human prompt. Fail-closed: an unavailable review denies
              # (failureMode "deny", not defer) so a broken reviewer can
              # never become a silent allow.
              authorizerChain = [
                "pi-auto-review"
              ];
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
                  # /tmp scratch cleanup is routine agent work — allow un-prompted.
                  # Later rules win over "rm -rf *" above (last-match-wins).
                  "rm -rf /tmp/*" = "allow";
                  "rm -fr /tmp/*" = "allow";
                  "nix build *" = "allow";
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
          "pi-auto-review" = {
            # Codex-style auto permission review (Claude Code Auto-mode
            # analogue). Model decision on "ask": allow/deny/defer. Uses the
            # openai-codex provider's codex-auto-review model (synthesized
            # from the provider template when not in the model store), so it
            # reuses your existing Codex OAuth login — no extra key.
            #
            # Notable defaults (differ from @mzwing/pi-permission-auto-review):
            # - failureMode "defer" (explicit): when the review cannot run
            #   (model/auth/timeout/parse), fall back to the human prompt
            #   instead of blocking outright.
            # - autoConfirmBoundedAllows ["external_directory","path"]: a
            #   model allow on a bounded surface is bound to the immediately
            #   following local permission dialog and auto-confirms it in the
            #   TUI (10s expiry, one-use, v24 compatibility bridge).
            # - circuit breaker: 3 consecutive or 10/50 recent denials stop
            #   automatic review until the next turn.
            config = {
              model = "openai-codex/codex-auto-review";
              # Defer to the human prompt when the review cannot run (the
              # package default is "deny" — fail-closed).
              failureMode = "defer";
              # reasoning = "low";    # default
              # timeoutMs = 45000;    # default
            };
          };
        };
        # pi-yaml-hooks notification hooks (modules/home-manager/llm/hooks/).
        # Written to <configDir>/hook/<name> = ~/.pi/agent/hook/ on every
        # activation (copy mode: editable until next rebuild; hot-reloaded
        # lazily by the plugin). Validate with /hooks-validate.
        files = {
          "hooks.yaml" = {
            text = ''
              # pi-yaml-hooks global config: notify on interactive interruptions.
              # Trigger timing depends on extension load order — pi-yaml-hooks is
              # declared BEFORE pi-permission-system in `packages` because pi runs
              # tool_call handlers sequentially and the permission gate awaits its
              # dialog inside its own handler.
              hooks:
                - id: notify-ask-user-question
                  event: tool.before.ask_user_question
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"

                - id: notify-permission-ask
                  event: tool.before.bash
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"

                - id: notify-goal-draft
                  event: tool.before.propose_goal_draft
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"

                - id: notify-loop-draft
                  event: tool.before.propose_loop_draft
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"

                - id: notify-task-list
                  event: tool.before.propose_task_list
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"

                - id: notify-loop-refine
                  event: tool.before.propose_loop_refine
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"

                - id: notify-subagent-checkpoint
                  event: tool.before.subagent
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"

                - id: notify-session-idle
                  event: session.idle
                  actions:
                    - bash: "${config.home.homeDirectory}/.pi/agent/hook/notify-prompt.sh"
            '';
          };
          "notify-prompt.sh" = {
            source = ./hooks/notify-prompt.sh;
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
          # C-n/C-p are occupied by selection movement; remap picker actions.
          "app.session.togglePath" = [ "ctrl+alt+l" ];
          "app.session.toggleNamedFilter" = [ "ctrl+shift+n" ];
          "app.models.toggleProvider" = [ "ctrl+alt+v" ];
        };
      };
      oh-my-pi = {
        enable = false;
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
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
