{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  libnotify,
  pwgen,
  util-linux,
  rofi-wayland,
  wtype,
  wl-clipboard,
  qrencode,
  pass-wayland,
}:
stdenv.mkDerivation {
  pname = "rofi-pass-wayland";
  version = "2.1.3-unstable-2024-12-10";

  src = fetchFromGitHub {
    owner = "Seme4eg";
    repo = "rofi-pass-wayland";
    rev = "c26dde937839a54977a0253f1a678ec6ce036df9";
    sha256 = "sha256-N1QuC7fZpDih/RTRFxm2eUy7JMCOMpGwur5orQ52610=";
  };

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    cp -a rofi-pass $out/bin/rofi-pass

    mkdir -p $out/share/doc/rofi-pass/
    cp -a config.example $out/share/doc/rofi-pass/config.example
  '';

  wrapperPath = lib.makeBinPath [
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    libnotify
    pwgen
    util-linux
    rofi-wayland
    (pass-wayland.withExtensions (ext: [ext.pass-otp]))
    wl-clipboard
    wtype
    qrencode
  ];

  meta = {
    description = "Rofi frontend for ZX2C4 pass project (wayland only).";
    homepage = "https://github.com/Seme4eg/rofi-pass-wayland";
    mainProgram = "rofi-pass";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [wenjinnn];
    platforms = with lib.platforms; linux;
  };
}
