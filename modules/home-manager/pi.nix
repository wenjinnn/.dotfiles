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

  npmEnv = "NPM_CONFIG_PREFIX=$HOME/.pi/npm PATH=${cfg.nodejs}/bin:$PATH";

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

    exec ${pkgs.pi-coding-agent}/bin/pi "$@"
  '';

  # Helper to check if a value is a derivation (package)
  isDerivation = x: lib.isDerivation x;

  # Get npm specifier from a derivation's package.json
  getNpmSpecifier = drv:
    let
      # Try to read package.json from the derivation
      pkgJsonPath = "${drv}/package.json";
      pkgJson = builtins.tryEval (builtins.fromJSON (builtins.readFile pkgJsonPath));
    in
    if pkgJson.success then
      "npm:" + pkgJson.value.name
    else
      builtins.toString drv;  # Fallback to store path

  # Process packages: derivations become npm specifiers, strings stay as-is
  processPackage = pkg:
    if lib.isString pkg then pkg
    else getNpmSpecifier pkg;

  # Separate packages into strings (for settings) and derivations (for symlinks)
  processPackages = packages:
    let
      strings = lib.filter lib.isString packages;
      derivations = lib.filter isDerivation packages;
      # Convert derivations to npm specifiers for settings
      settingsEntries = map processPackage packages;
    in
      {
        settings = settingsEntries;
        derivations = derivations;
      };

  processedPackages = processPackages (cfg.packages ++ cfg.extraPackages);

  # Merge settings with processed packages
  finalSettings = cfg.settings // {
    packages = (cfg.settings.packages or []) ++ processedPackages.settings;
  };
in
{
  options.programs.pi = {
    enable = lib.mkEnableOption "pi coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = piWrapper;
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
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.package);
      default = [ ];
      description = ''
        Extension pi packages. Can be:
          - String specifiers: "npm:@foo/bar" or "git:github.com/user/repo"
          - Nix packages from piPackages: pkgs.piPackages.pi-mcp-adapter
      '';
    };

    # Additional pi packages to install (derivations only)
    # These are installed to ~/.pi/npm/lib/node_modules/
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        Pi packages as Nix derivations to install declaratively.
        These are linked to ~/.pi/npm/lib/node_modules/ for pi to discover.
        Use pkgs.piPackages.* to reference available packages.
      '';
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

    # Symlink pi packages to ~/.pi/npm/lib/node_modules/
    home.activation.pi-packages-link = lib.mkIf (processedPackages.derivations != []) (
      let
        # Get package name from derivation's package.json
        linkCommands = map (drv: ''
          # Read package name from package.json
          if [ -f "${drv}/package.json" ]; then
            pkg_name=$(${pkgs.nodejs}/bin/node -e "console.log(JSON.parse(require('fs').readFileSync('${drv}/package.json', 'utf8')).name)")
            if [ -n "$pkg_name" ]; then
              # Handle scoped packages
              if [[ "$pkg_name" == @* ]]; then
                # Extract scope and name
                scope="''${pkg_name%%/*}"
                name="''${pkg_name#*/}"
                mkdir -p "$HOME/.pi/npm/lib/node_modules/$scope"
                ln -sfn "${drv}" "$HOME/.pi/npm/lib/node_modules/$scope/$name"
              else
                mkdir -p "$HOME/.pi/npm/lib/node_modules"
                ln -sfn "${drv}" "$HOME/.pi/npm/lib/node_modules/$pkg_name"
              fi
            fi
          fi
        '') processedPackages.derivations;
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.pi/npm/lib/node_modules"
        ${lib.concatStringsSep "\n" linkCommands}
      ''
    );

    home.file = {
      ".pi/agent/auth.json" = lib.mkIf (cfg.auth != { }) {
        text = builtins.toJSON cfg.auth;
      };
      ".pi/agent/settings.json" = lib.mkIf (cfg.auth != { }) {
        text = builtins.toJSON finalSettings;
      };
      ".pi/agent/keybindings.json" = lib.mkIf (cfg.keybindings != { }) {
        text = builtins.toJSON cfg.keybindings;
      };
      ".pi/agent/models.json" = lib.mkIf (cfg.customProviders != { }) {
        text = builtins.toJSON { providers = cfg.customProviders; };
      };
    };
  };
}
