{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--glob=!.git/*"
      "--smart-case"
      "--hidden"
    ];
  };
}
