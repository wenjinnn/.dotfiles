{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # podman mirrors
  home.file = {
    ".config/containers/registries.conf".text = ''
      unqualified-search-registries = ["docker.io"]

      [[registry]]
      prefix = "docker.io"
      insecure = false
      blocked = false
      location = "docker.io"
      [[registry.mirror]]
      location = "hub-mirror.c.163.com"
      [[registry.mirror]]
      location = "registry.docker-cn.com"
    '';
  };
}
