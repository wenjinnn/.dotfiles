{
  config,
  lib,
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
            mountPoint = "/mnt/rclone/gd";
          };
        };
      };
      nextcloud = {
        config = {
          type = "webdav";
          url = "http://nextcloud.ts.${me.domain}/remote.php/dav/files/${me.username}";
          vendor = "nextcloud";
          user = me.username;
        };
        secrets = {
          pass = config.sops.secrets.NEXTCLOUD_WEBDAV_PASS.path;
        };
        mounts = {
          "/" = {
            enable = true;
            mountPoint = "/mnt/rclone/nextcloud";
          };
        };
      };
    };
  };

  home.activation.rcloneLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/Rclone"
    for name in gd nextcloud; do
      link="$HOME/Rclone/$name"
      target="/mnt/rclone/$name"
      if [ -d "$link" ] && [ ! -L "$link" ]; then
        rmdir "$link" || {
          echo "refusing to replace non-empty rclone mount point: $link" >&2
          exit 1
        }
      fi
      ln -sfn "$target" "$link"
    done
  '';
}
