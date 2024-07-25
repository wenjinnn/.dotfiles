{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--glob=!.git/*"
      "--glob=!**/target"
      "--glob=!**/node_modules"
      "--glob=!**/tags"
      "--glob=!**/rime/*.dict.yaml"
      "--glob=!**/.direnv"
      "--smart-case"
      "--hidden"
      "--no-ignore-vcs"
    ];
  };
}
