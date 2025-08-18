{
  inputs,
  config,
  pkgs,
  ...
}:
{
  home.packages = (
    with pkgs;
    [
      neovim-remote
      # lsp related
      jdt-language-server
      lombok
      lua-language-server
      bash-language-server
      vue-language-server
      vscode-langservers-extracted
      nur.repos.wenjinnn.lemminx-maven
      clang-tools
      nixd
      rust-analyzer
      typescript-language-server
      vtsls
      vue-language-server
      yaml-language-server
      vim-language-server
      texlab
      taplo
      gopls
      # linter
      vale
      eslint
      # formatter
      stylua
      libxml2
      alejandra
      nixfmt-rfc-style
      rustfmt
      prettier
      black
      # for nvim-treesitter
      tree-sitter
      # another http tool
      hurl
      # for kulala.nvim
      grpcurl
      websocat
      openssl
      # for vim-dadbod
      mariadb
      redis
      oracle-instantclient
      basedpyright
      ruff
    ]
  );
  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.DOTFILES}/xdg/config/nvim";
    };
    "vale/.vale.ini".text = ''
      MinAlertLevel = suggestion

      [*]
      BasedOnStyles = Vale
    '';
  };
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    withRuby = true;
    withNodeJs = true;
    withPython3 = true;

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
      "${pkgs.vue-language-server}/lib/language-tools/packages/language-server"
    ];
  };
}
