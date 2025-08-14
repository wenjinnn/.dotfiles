{ pkgs, config, ... }:
let
  mpd_fifo = "${config.home.homeDirectory}/.local/share/mpd/mpd.fifo";
in
{
  home.packages = [
    pkgs.mpc
  ];
  services = {
    mpd-mpris.enable = true;
    mpd = {
      enable = true;
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
        audio_output {
            type "fifo"
            name "visualizer"
            path "${mpd_fifo}"
            format "44100:16:2"
        }
      '';
    };
  };
  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };
    settings = {
      visualizer_data_source = "${mpd_fifo}";
      visualizer_output_name = "visualizer";
      visualizer_in_stereo = "yes";
      visualizer_type = "spectrum";
      visualizer_look = "+|";
    };
    bindings = [
      {
        key = "j";
        command = "scroll_down";
      }
      {
        key = "k";
        command = "scroll_up";
      }
      {
        key = "J";
        command = [
          "select_item"
          "scroll_down"
        ];
      }
      {
        key = "K";
        command = [
          "select_item"
          "scroll_up"
        ];
      }
    ];
  };
}
