{ 
  pkgs,
  ...
} : {
  home.packages = with pkgs; [
    (python311.withPackages (p: [ p.python-pam ]))
    gnumake
    cmake
    gcc
    nodejs
    jdk21
    maven.override { jdk = jdk21; }
    rustc
    cargo
  ];

}
