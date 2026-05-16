{
  config,
  username,
  ...
}:
{
  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age = {
      generateKey = true;
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/etc/ssh/age/keys.txt";
    };
    secrets = {
      MIHOMO_PROVIDER = { };
      MIHOMO_PROVIDER2 = { };
      RPI5_PASS = { };
      RPI5_TAILSCALE_AUTHKEY = { };
      RPI5_ARIA2_SECRET = { };
      NEXTCLOUD_ADMIN_PASS = { };
      NEXTCLOUD_DB_PASS = { };
      K3S_TOKEN = { };
      CACHIX_TOKEN = { };
    };
  };
}
