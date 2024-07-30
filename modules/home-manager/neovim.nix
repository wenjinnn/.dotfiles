{
  config,
  pkgs,
  ...
}: let
  repoPath = "${config.home.homeDirectory}/project/my/config";
  archivePath = "${config.home.homeDirectory}/project/my/archive";
in {
  home.packages = with pkgs; [
    hurl
    lua-language-server
    vscode-langservers-extracted
    clang-tools
    rust-analyzer
    rustfmt
    lemminx
    marksman
    unstable.nixfmt-rfc-style
    # stylua
    unstable.luajitPackages.luarocks-nix
    python311Packages.pip
    python311Packages.python-lsp-server
    tree-sitter
    # for vim-dadbod
    mysql
    redis
  ];

  home.sessionVariables = {
    JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
    JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
    JAVA_21_HOME = "${pkgs.jdk21}/lib/openjdk";
    LAZY_NVIM_LOCK_PATH = "${repoPath}/xdg/config/nvim/";
    NVIM_SPELLFILE = "${archivePath}/nvim/spell/en.utf-8.add";
    SOPS_SECRETS = "${repoPath}/secrets.yaml";
  };
  home.file = {
    ".config/nvim" = {
      source = ../../xdg/config/nvim;
      recursive = true;
    };
    ".config/vale/.vale.ini".text = ''
      MinAlertLevel = suggestion

      [*]
      BasedOnStyles = Vale
    '';
  };
  programs.neovim = {
    package = pkgs.unstable.neovim-unwrapped;
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    withRuby = true;
    withNodeJs = true;
    withPython3 = true;
    # for rest.nvim v2
    # extraLuaPackages = luaPkgs: with pkgs.unstable.luajitPackages; [
    #   lua-curl
    #   nvim-nio
    #   xml2lua
    #   mimetypes
    # ];
    extraPython3Packages = pyPkgs:
      with pyPkgs; [
        pynvim
      ];
  };
}
