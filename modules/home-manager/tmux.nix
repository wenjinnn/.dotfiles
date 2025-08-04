{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-q";
    aggressiveResize = true;
    clock24 = true;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    historyLimit = 10000;
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      open
      yank
      sensible
      logging
      sessionist
      pain-control
      tmux-floax
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];
    extraConfig = ''
      set -g status off
      set -g pane-border-status top
      set -g pane-border-format '#[bold]#{?client_prefix,#[underscore],} \
      [#S]:#I/#{session_windows}:#{pane_index} #{pane_current_command} #{pane_current_path} \
      #{?window_zoomed_flag,Z ,}#[default]'
      # True color support
      set -ag terminal-overrides ",$TERM:RGB"
      # Undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      # Underscore colors
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';
  };
}
