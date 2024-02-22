{
  config,
  pkgs,
  ...
}: let 
  repoPath = "${config.home.homeDirectory}/project/my/config";
  in {

  home.packages = with pkgs; [
    lua-language-server
    vscode-langservers-extracted
    clang-tools
    rust-analyzer
    rustfmt
    lemminx
    marksman
    stylua
  ];

  home.sessionVariables = {
    JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
    JAVA_21_HOME = "${pkgs.jdk21}/lib/openjdk";
    ESLINT_LIBRARY = "${pkgs.vscode-langservers-extracted}/lib/node_modules/vscode-langservers-extracted/node_modules";
    LAZY_NVIM_LOCK_PATH = "${repoPath}/xdg/config/nvim/";
  };
  home.file = {
    ".config/nvim" = {
      source = ../../xdg/config/nvim;
      recursive = true;
    };
    ".config/nvim/lazy-lock.json".enable = false;
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    withRuby = true;
    withNodeJs = true;
    withPython3 = true;

    extraPackages = with pkgs; [
      cargo
      unzip
      jdk8
      jdk21
      wget
      curl
      tree-sitter
      luajitPackages.luarocks
      python311Packages.pynvim
      python311Packages.pip
      gcc
    ];
  };


}
