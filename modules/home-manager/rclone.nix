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
      rpi5 = {
        config = {
          type = "smb";
          host = "rpi5";
          user = me.username;
        };
        secrets = {
          pass = config.sops.secrets.RPI5_SMB_PASS.path;
        };
        mounts = {
          "/" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/Rclone/rpi5";
          };
        };
      };
    };
  };
}
