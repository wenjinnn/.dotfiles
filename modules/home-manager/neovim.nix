{
  config,
  pkgs,
  ...
}: let 
  repoPath = "${config.home.homeDirectory}/project/my/config";
  in {

  home.packages = with pkgs; [
    lua-language-server
    clang-tools
    rustc
    cargo
    rust-analyzer
    rustfmt
    maven
    lemminx
    marksman
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
    JAVA_21_HOME = "${pkgs.jdk21}/lib/openjdk";
    LAZY_NVIM_LOCK_PATH = "${repoPath}/xdg/config/nvim/";
    GTK_THEME = "Adwaita-dark";
  };
  home.file = {
    ".m2/toolchains.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <toolchains>
        <!-- JDK toolchains -->
        <toolchain>
          <type>jdk</type>
          <provides>
            <version>8</version>
          </provides>
          <configuration>
            <jdkHome>${pkgs.jdk8}/lib/openjdk</jdkHome>
          </configuration>
        </toolchain>
      </toolchains>
    '';
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
