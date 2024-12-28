{
  config,
  pkgs,
  ...
}: {
  home.packages =
    (with pkgs; [
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
      texlab
      taplo
      gopls
      libxml2
      # for vim-dadbod
      mariadb
      redis
      oracle-instantclient
    ])
    ++ (with pkgs.python3Packages; [
      python-lsp-server
      pip
    ]);

  home.sessionVariables = {
    JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
    JAVA_17_HOME = "${pkgs.jdk17}/lib/openjdk";
    JAVA_21_HOME = "${pkgs.jdk21}/lib/openjdk";
  };
  home.file = {
    ".config/nvim" = {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.DOTFILES}/xdg/config/nvim";
    };
    ".config/vale/.vale.ini".text = ''
      MinAlertLevel = suggestion

      [*]
      BasedOnStyles = Vale
    '';
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

    extraPython3Packages = pyPkgs:
      with pyPkgs; [
        pynvim
      ];

    extraWrapperArgs = [
      "--suffix"
      "JAVA_TEST_PATH"
      ":"
      "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test"
      "--suffix"
      "JAVA_DEBUG_PATH"
      ":"
      "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug"
      "--suffix"
      "LOMBOK_PATH"
      ":"
      "${pkgs.lombok}/share/java"
      "--suffix"
      "SONARLINT_PATH"
      ":"
      "${pkgs.vscode-extensions.sonarsource.sonarlint-vscode}/share/vscode/extensions/sonarsource.sonarlint-vscode/"
      "--suffix"
      "VUE_LANGUAGE_SERVER_PATH"
      ":"
      "${pkgs.vue-language-server}/lib/node_modules/@vue/language-server"
      "--suffix"
      "TYPESCRIPT_LIBRARY"
      ":"
      "${pkgs.typescript}/lib/node_modules/typescript/lib"
    ];
  };
}
