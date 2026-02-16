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
  };
}
