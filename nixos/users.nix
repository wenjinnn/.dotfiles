{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    ${username} = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      home = "/home/${username}";
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "audio"
        "video"
        "libvirtd"
      ];
    };
    ollama = {
      home = "/home/ollama";
      isSystemUser = true;
      createHome = true;
    };
  };
}
