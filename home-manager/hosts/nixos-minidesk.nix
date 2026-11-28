{
  config,
  inputs,
  me,
  outputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    outputs.homeManagerModules.starship
    outputs.homeManagerModules.llm
    outputs.homeManagerModules.easyeffects
    ../syncthing.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
    config.allowUnfree = true;
  };

  home = {
    username = me.username;
    homeDirectory = "/home/${me.username}";
    stateVersion = "26.05";
    sessionVariables.SOPS_SECRETS = "${config.home.homeDirectory}/.dotfiles/secrets.yaml";
  };

  systemd.user.services.easyeffects = {
    Install.WantedBy = [ "default.target" ];
    Service.Environment = [ "QT_QPA_PLATFORM=offscreen" ];
  };

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age = {
      generateKey = false;
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
    secrets = {
      DEEPSEEK_API_KEY = { };
      MIMO_API_KEY = { };
      GEMINI_API_KEY = { };
      OPENROUTER_API_KEY = { };
      SYNCTHING_GUI_PASSWORD = { };
    };
  };
}
