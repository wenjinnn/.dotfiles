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
    unstable.luajitPackages.luarocks-nix
    python311Packages.pip
    python311Packages.python-lsp-server
    tree-sitter
  ];

  home.sessionVariables = {
    JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
    JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
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
    extraLuaPackages = luaPkgs: with pkgs.unstable.luajitPackages; [
      lua-curl
      nvim-nio
      xml2lua
    ];
    extraPython3Packages = pyPkgs: with pyPkgs; [
      pynvim
    ];
  };
}
