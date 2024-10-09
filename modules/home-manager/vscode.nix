{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps:
      with ps; [
        rustup
        zlib
        openssl.dev
        pkg-config
        jdk21
        nodejs
      ]);
  };
}
