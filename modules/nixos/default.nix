# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  interception-tools = import ./interception-tools.nix;
  firewall = import ./firewall.nix;
  virt = import ./virt.nix;
  docker = import ./docker.nix;
  podman = import ./podman.nix;
  systemd-boot = import ./systemd-boot.nix;
  wsl = import ./wsl.nix;
  fonts = import ./fonts.nix;
  xserver = import ./xserver.nix;
  gnome = import ./gnome.nix;
  hyprland = import ./hyprland.nix;
  sing-box = import ./sing-box.nix;
  bluetooth = import ./bluetooth.nix;
  waydroid = import ./waydroid.nix;
  ollama = import ./ollama.nix;
  mihomo = import ./mihomo.nix;
  sops = import ./sops.nix;
  mail = import ./mail.nix;
  steam = import ./steam.nix;
  theme = import ./theme.nix;
  fcitx5 = import ./fcitx5.nix;
}
