{
  config,
  pkgs,
  ...
}: {

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      direnv.disabled = false;
      directory = {
        truncation_symbol = "…/";
        truncate_to_repo = false;
      };
      git_metrics.disabled = false;
      localip = {
        ssh_only = false;
        disabled = false;
      };
      memory_usage.disabled = false;
      os.disabled = false;
      shell.disabled = false;
      shlvl.disabled = false;
      status.disabled = false;
      sudo.disabled = false;
      time.disabled = false;
      battery.display.threshold = 20;
      continuation_prompt = "▶▶ ";
      fill.symbol = " ";
      format = "$os$all";
      right_format = "$shlvl$time$memory_usage$localip";
    };
  };

}
