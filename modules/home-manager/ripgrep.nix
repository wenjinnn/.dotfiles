{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--glob=!.git/*"
      "--glob=!**/target"
      "--glob=!**/node_modules"
      "--smart-case"
      "--hidden"
      "--no-ignore-vcs"
    ];
  };
}
