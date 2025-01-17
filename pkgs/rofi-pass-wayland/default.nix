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
    owner = "wenjinnn";
    repo = "rofi-pass-wayland";
    rev = "7a096a690d03bfde626401e732e2c100c3e17a48";
    sha256 = "sha256-8MA16bsAODnViz0enPQqJdRB9AmH+XEARdBdE3VqQmQ=";
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
    homepage = "https://github.com/wenjinnn/rofi-pass-wayland";
    mainProgram = "rofi-pass";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [wenjinnn];
    platforms = with lib.platforms; linux;
  };
}
