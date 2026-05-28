# modified from https://github.com/vabatta/pi-nix/blob/main/modules/pi.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pi;

  builtinProviders = [
    # Subscription
    "chatgpt"
    "claude"
    "github-copilot"
    # API key
    "anthropic"
    "openai"
    "azure-openai-responses"
    "deepseek"
    "google"
    "mistral"
    "groq"
    "cerebras"
    "cloudflare-ai-gateway"
    "cloudflare-workers-ai"
    "xai"
    "openrouter"
    "vercel-ai-gateway"
    "zai"
    "opencode"
    "opencode-go"
    "huggingface"
    "fireworks"
    "together"
    "kimi-coding"
    "minimax"
    "minimax-cn"
    "xiaomi"
    "xiaomi-token-plan-cn"
    "xiaomi-token-plan-ams"
    "xiaomi-token-plan-sgp"
    "amazon-bedrock"
  ];

  modelType = lib.types.submodule {
    options = {
      id = lib.mkOption {
        type = lib.types.str;
        description = "Model identifier";
      };
      name = lib.mkOption {
        type = lib.types.str;
        description = "Display name";
      };
      input = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "text" ];
        description = "Input modalities";
      };
      contextWindow = lib.mkOption {
        type = lib.types.int;
        default = 131072;
        description = "Context window size";
      };
    };
  };

  providerType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Display name";
      };
      baseUrl = lib.mkOption {
        type = lib.types.str;
        description = "API base URL";
      };
      api = lib.mkOption {
        type = lib.types.str;
        default = "openai-completions";
        description = "API protocol";
      };
      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "API key or env var name";
      };
      models = lib.mkOption {
        type = lib.types.listOf modelType;
        default = [ ];
        description = "Available models";
      };
    };
  };

  authEntryType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.str;
        default = "api_key";
        description = "Auth type";
      };
      key = lib.mkOption {
        type = lib.types.str;
        description = "API key, env var, or deferred command (prefix with !)";
      };
    };
  };

  # settingsJson = builtins.toJSON settingsBase;

  keybindingsJson = builtins.toJSON cfg.keybindings;

  npmEnv = "NPM_CONFIG_PREFIX=$HOME/.pi/npm PATH=${cfg.nodejs}/bin:$PATH";

  # Settings script depends on mutableSettings

  # Wrapper pre-launch hook
  preLaunchScript = lib.optionalString (cfg.preLaunchHook != "") ''
    ${cfg.preLaunchHook}
  '';

  piWrapper = pkgs.writeShellScriptBin "pi" ''
    # npm on PATH for extension management (pi install)
    export NPM_CONFIG_PREFIX="$HOME/.pi/npm"
    export PATH="${cfg.nodejs}/bin:$PATH"
    export PI_SKIP_VERSION_CHECK=1
    export PI_OFFLINE=1

    ${preLaunchScript}

    exec ${cfg.package}/bin/pi "$@"
  '';
in
{
  options.programs.pi = {
    enable = lib.mkEnableOption "pi coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pi-coding-agent;
      description = "The pi package to use";
    };

    nodejs = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs;
      description = "Node.js package for extension management (encapsulated, not on global PATH)";
    };

    auth = lib.mkOption {
      type = lib.types.attrsOf authEntryType;
      default = { };
      description = "Per-provider authentication credentials";
    };

    customProviders = lib.mkOption {
      type = lib.types.attrsOf providerType;
      default = { };
      description = "Custom provider definitions (written to models.json)";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extension pi package specifiers (npm:... or git:...)";
    };

    mutableSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Seed settings once (true) vs overwrite every launch (false)";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra settings merged into settings.json";
    };

    keybindings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra keybindings merged into keybindings.json";
    };

    preLaunchHook = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Shell commands to run before launching pi (after settings.json is written). Has access to $settings_file. Useful for theme sync or env-based overrides.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ piWrapper ];

    home.shellAliases = lib.optionalAttrs cfg.mutableSettings {
      "pi-reset-config" =
        "rm -f $HOME/.pi/agent/settings.json && echo 'Settings reset. Next pi launch will re-seed from nix config.'";
    };

    home.file = {
      ".pi/agent/auth.json" = lib.mkIf (cfg.auth != { }) {
        text = builtins.toJSON cfg.auth;
      };
      ".pi/agent/settings.json" = lib.mkIf (cfg.auth != { }) {
        text = builtins.toJSON cfg.settings;
      };
      ".pi/agent/keybindings.json" = lib.mkIf (cfg.auth != { }) {
        text = builtins.toJSON cfg.keybindings;
      };
      ".pi/agent/models.json" = lib.mkIf (cfg.customProviders != { }) {
        text = builtins.toJSON { providers = cfg.customProviders; };
      };
    };
  };
}
