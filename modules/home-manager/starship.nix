{
  config,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      direnv.disabled = false;
      directory = {
        truncation_symbol = "…/";
        truncate_to_repo = false;
      };
      git_metrics.disabled = false;
      git_status = {
        diverged = "⇡$ahead_count⇣$behind_count";
        conflicted = "=$count";
        ahead = "⇡$count";
        behind = "⇣$count";
        untracked = "?$count";
        stashed = "+$count";
        modified = "!$count";
        staged = "\\$$count";
        renamed = "»$count";
        deleted = "✘$count";
      };
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
      continuation_prompt = "▶▶ ";
      fill.symbol = " ";
      format = "$os$all";
      env_var.HTTP_PROXY = {
        variable = "HTTP_PROXY";
        default = "";
        format = "(🛰️ [$env_value]($style) )";
        style = "bright-blue bold";
        description = "The proxy environment variable";
      };
    };
  };
}
