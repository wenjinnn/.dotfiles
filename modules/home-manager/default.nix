# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  hyprland = import ./hyprland.nix;
  zsh = import ./zsh.nix;
  foot = import ./foot.nix;
  neovim = import ./neovim.nix;
  git = import ./git.nix;
  fcitx5 = import ./fcitx5.nix;
  theme = import ./theme.nix;
  fuzzel = import ./fuzzel.nix;
  ctags = import ./ctags.nix;
  yazi = import ./yazi.nix;
  mpv = import ./mpv.nix;
  mime = import ./mime.nix;
  git-sync = import ./git-sync.nix;
  gnome-terminal = import ./gnome-terminal.nix;
  tmux = import ./tmux.nix;
  wezterm = import ./wezterm.nix;
  lang = import ./lang.nix;
  btop = import ./btop.nix;
  vscode = import ./vscode.nix;
  direnv = import ./direnv.nix;
  translate-shell = import ./translate-shell.nix;
  aria2 = import ./aria2.nix;
  starship = import ./starship.nix;
  ripgrep = import ./ripgrep.nix;
  sops = import ./sops.nix;
  mail = import ./mail.nix;
  zellij = import ./zellij.nix;
  mpd = import ./mpd.nix;
  rofi = import ./rofi.nix;
  waybar = import ./waybar.nix;
  waybar-vertical = import ./waybar-vertical.nix;
  wallpaper = import ./wallpaper.nix;
  browser = import ./browser.nix;
  syncthing = import ./syncthing.nix;
  rclone = import ./rclone.nix;
  niri = import ./niri.nix;
  cliphist = import ./cliphist.nix;
  dunst = import ./dunst.nix;
  kdeconnect = import ./kdeconnect.nix;
  udiskie = import ./udiskie.nix;
  de-basic = import ./de-basic.nix;
  opencode = import ./opencode.nix;
  bash = import ./bash.nix;
}
