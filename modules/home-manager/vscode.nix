{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode.fhsWithPackages (ps:
      with ps; [
        rustup
        zlib
        openssl.dev
        pkg-config
        jdk8
        jdk17
        jdk21
        nodejs
      ]);
  };
}
