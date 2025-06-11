{
  config,
  outputs,
  ...
}:
{
  imports = with outputs.homeManagerModules; [
    sops
  ];
  programs.rclone = {
    enable = true;
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
          "" = {
            enable = true;
            mountPoint = "${config.home.homeDirectory}/Rclone/gd";
          };
        };
      };
    };
  };
}
