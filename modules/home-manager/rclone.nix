{
  config,
  outputs,
  me,
  pkgs,
  ...
}:
let
  warmup = pkgs.writeShellScript "rclone-metadata-warmup" ''
    set -u

    warm_mount() {
      local mount_point=$1
      for _ in $(${pkgs.coreutils}/bin/seq 1 30); do
        if ${pkgs.coreutils}/bin/ls -la "$mount_point" >/dev/null 2>&1; then
          return 0
        fi
        ${pkgs.coreutils}/bin/sleep 1
      done
      return 0
    }

    warm_mount "${config.home.homeDirectory}/Rclone/gd" &
    warm_mount "${config.home.homeDirectory}/Rclone/nextcloud" &
    wait
  '';
in
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
            mountPoint = "${config.home.homeDirectory}/Rclone/nextcloud";
          };
        };
      };
    };
  };

  # Prime each remote's root directory so Nautilus does not make the first
  # network metadata request during its initial startup.
  systemd.user.services.rclone-metadata-warmup = {
    Unit = {
      Description = "Warm rclone mount metadata";
      Requires = [
        "rclone-mount:.@gd.service"
        "rclone-mount:.@nextcloud.service"
      ];
      After = [
        "rclone-mount:.@gd.service"
        "rclone-mount:.@nextcloud.service"
      ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = warmup;
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
