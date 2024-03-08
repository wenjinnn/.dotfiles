{pkgs, ...}: {
  home.packages = with pkgs; [
    (python311.withPackages (p: [p.python-pam]))
    gnumake
    cmake
    gcc
    unstable.gdb
    nodejs
    jdk21
    (maven.override {jdk = pkgs.jdk21;})
    rustc
    cargo
  ];

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
  };
}
