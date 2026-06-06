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
      MIHOMO_PROVIDER3 = { };
      RPI5_PASS = { };
      RPI5_TAILSCALE_AUTHKEY = { };
      RPI5_ARIA2_SECRET = { };
      NEXTCLOUD_ADMIN_PASS = { };
      NEXTCLOUD_DB_PASS = { };
      K3S_TOKEN = { };
      CACHIX_TOKEN = { };
      MIMO_API_KEY = { };
      TELEGRAM_BOT_TOKEN = { };
      TELEGRAM_ALLOWED_USERS = { };
      WEIXIN_ACCOUNT_ID = { };
      WEIXIN_TOKEN = { };
      WEIXIN_ALLOWED_USERS = { };
    };
    templates = {
      "hermes-env.yaml".content = ''
        hermes-env: |
            XIAOMI_BASE_URL=https://token-plan-cn.xiaomimimo.com/v1
            XIAOMI_API_KEY=${config.sops.placeholder.MIMO_API_KEY}
            TELEGRAM_BOT_TOKEN=${config.sops.placeholder.TELEGRAM_BOT_TOKEN}
            TELEGRAM_ALLOWED_USERS=${config.sops.placeholder.TELEGRAM_ALLOWED_USERS}
            WEIXIN_ACCOUNT_ID=${config.sops.placeholder.WEIXIN_ACCOUNT_ID}
            WEIXIN_TOKEN=${config.sops.placeholder.WEIXIN_TOKEN}
            WEIXIN_DM_POLICY=allowlist
            WEIXIN_ALLOWED_USERS=${config.sops.placeholder.WEIXIN_ALLOWED_USERS}
      '';
    };
  };
}
