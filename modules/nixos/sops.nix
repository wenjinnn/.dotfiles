{
  config,
  username,
  ...
}: {
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age = {
      generateKey = true;
      sshKeyPaths = ["${config.users.users.${username}.home}/.ssh/id_ed25519"];
      keyFile = "${config.users.users.${username}.home}/.config/sops/age/keys.txt";
    };
    secrets.MIHOMO_PROVIDER = {};
    secrets.MIHOMO_PROVIDER2 = {};
  };
}
