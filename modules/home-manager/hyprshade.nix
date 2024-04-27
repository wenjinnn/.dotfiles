{
  pkgs,
  ...
}: {

  home.packages = [
    pkgs.unstable.hyprshade
  ];

  home.file = {
    ".config/hypr/hyprshade.toml".text = ''
      [[shades]]
      name = "vibrance"
      default = true  # shader to use during times when there is no other shader scheduled

      [[shades]]
      name = "blue-light-filter"
      start_time = 18:30:00
      end_time = 06:00:00   # optional if you have more than one shade with start_time
    '';
  };
}
