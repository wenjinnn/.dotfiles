{
  config,
  username,
  ...
}: {
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age = {
      generateKey = true;
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/etc/ssh/age/keys.txt";
    };
    secrets.MIHOMO_PROVIDER = { };
    secrets.MIHOMO_PROVIDER2 = { };
    secrets.RPI5_PASS = { };
    secrets.RPI5_TAILSCALE_AUTHKEY = { };
    secrets.RPI5_ARIA2_SECRET = { };
    secrets.NEXTCLOUD_ADMIN_PASS = { };
    secrets.NEXTCLOUD_DB_PASS = { };
    secrets.MATRIX_REGISTRATION_TOKEN = { };
    secrets.MATRIX_REGISTRATION_TOKEN.owner = config.services.matrix-tuwunel.user;
    secrets.MATRIX_REGISTRATION_TOKEN.group = config.services.matrix-tuwunel.group;
  };
}
