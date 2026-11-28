{ ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    # Verified over SSH: Samsung SSD 990 EVO Plus 1TB, serial S7U4NJ0XB41129L.
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_EVO_Plus_1TB_S7U4NJ0XB41129L";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        system = {
          size = "100%";
          type = "8300";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = {
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "/nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "/home" = {
                mountpoint = "/home";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
