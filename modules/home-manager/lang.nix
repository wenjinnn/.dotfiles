{pkgs, ...}: {
  home.packages = with pkgs; [
    (python3.withPackages (p: [
      p.python-pam
      p.debugpy
      p.msal
    ]))
    gnumake
    cmake
    gcc
    gdb
    nodejs
    jdk21
    maven
    rustc
    cargo
  ];

  home.file = {
    ".local/lib/openjdk8".source = "${pkgs.jdk8}/lib/openjdk";
    ".local/lib/openjdk17".source = "${pkgs.jdk17}/lib/openjdk";
    ".local/lib/openjdk21".source = "${pkgs.jdk21}/lib/openjdk";
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
    ".m2/settings.xml".text = ''
      <settings>
          <mirrors>
              <mirror>
                  <id>maven-default-http-blocker</id>
                  <mirrorOf>dummy</mirrorOf>
                  <name>Dummy mirror to override default blocking mirror that blocks http</name>
                  <url>http://0.0.0.0/</url>
              </mirror>
          </mirrors>
      </settings>
    '';
  };
}
