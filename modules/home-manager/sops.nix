{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age = {
      generateKey = true;
      sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt"; # must have no password!
    };
    secrets.OUTLOOK_CLIENT_ID = { };
    secrets.GMAIL_CLIENT_ID = { };
    secrets.GMAIL_CLIENT_SECRET = { };
    secrets.RCLONE_TOKEN = { };
  };

  home.packages = with pkgs; [
    ssh-to-age
    age
    sops
  ];
}
