{
  config,
  pkgs,
  ...
}: let
  repoPath = "${config.home.homeDirectory}/project/my/config";
  archivePath = "${config.home.homeDirectory}/project/my/archive";
in {
  home.packages =
    (with pkgs.unstable; [
      hurl
      jdt-language-server
      lombok
      lua-language-server
      bash-language-server
      vue-language-server
      vscode-langservers-extracted
      lemminx
      clang-tools
      nixd
      rust-analyzer
      vale-ls
      rustfmt
      lemminx
      alejandra
      nixfmt-rfc-style
      stylua
      luajitPackages.luarocks-nix
      tree-sitter
      typescript
      typescript-language-server
      vue-language-server
      yaml-language-server
      vim-language-server
      taplo
      # for vim-dadbod
      mysql
      redis
    ])
    ++ (with pkgs.unstable.python311Packages; [
      python-lsp-server
      pip
    ]);

  home.sessionVariables = {
    JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
    JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
    JAVA_21_HOME = "${pkgs.jdk21}/lib/openjdk";
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

    extraPython3Packages = pyPkgs:
      with pyPkgs; [
        pynvim
      ];

    extraWrapperArgs = [
      "--suffix"
      "JAVA_TEST_PATH"
      ":"
      "${pkgs.unstable.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test"
      "--suffix"
      "JAVA_DEBUG_PATH"
      ":"
      "${pkgs.unstable.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug"
      "--suffix"
      "LOMBOK_PATH"
      ":"
      "${pkgs.unstable.lombok}/share/java"
      "--suffix"
      "NVIM_MINI_DEPS_SNAP"
      ":"
      "${repoPath}/xdg/config/nvim/mini-deps-snap"
      "--suffix"
      "NVIM_SPELLFILE"
      ":"
      "${archivePath}/nvim/spell/en.utf-8.add"
      "--suffix"
      "SONARLINT_PATH"
      ":"
      "${pkgs.unstable.vscode-extensions.sonarsource.sonarlint-vscode}/share/vscode/extensions/sonarsource.sonarlint-vscode/"
      "--suffix"
      "VUE_LANGUAGE_SERVER_PATH"
      ":"
      "${pkgs.unstable.vue-language-server}/lib/node_modules/@vue/language-server"
      "--suffix"
      "TYPESCRIPT_LIBRARY"
      ":"
      "${pkgs.unstable.typescript}/lib/node_modules/typescript/lib"
    ];
  };
}
