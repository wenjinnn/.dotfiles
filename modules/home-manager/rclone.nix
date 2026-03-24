{
  config,
  outputs,
  me,
  ...
}:
{
  imports = with outputs.homeManagerModules; [
    sops
  ];
  programs.rclone = {
    enable = true;
    # must start after sops-nix.service to ensure secrets are available
    requiresUnit = "sops-nix.service";
    remotes = {
      gd = {
        config = {
          type = "drive";
          scope = "drive";
        };
        secrets = {
          token = config.sops.secrets.RCLONE_TOKEN.path;
        };
        mounts = {
          "/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/Rclone/gd";
          };
        };
      };
      nextcloud = {
        config = {
          type = "webdav";
          url = "http://nextcloud.ts.wenjin.me/remote.php/dav/files/wenjin";
          vendor = "nextcloud";
          user = me.username;
        };
        secrets = {
          pass = config.sops.secrets.NEXTCLOUD_WEBDAV_PASS.path;
        };
        mounts = {
          "/" = {
            enable = true;
            autoMount = false;
            mountPoint = "${config.home.homeDirectory}/Rclone/nextcloud";
          };
        };
      };
    };
  };
}
