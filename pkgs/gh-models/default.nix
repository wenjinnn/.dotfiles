{
  stdenv,
  lib,
  fetchurl,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  systemToPlatform = {
    "x86_64-linux" = {
      name = "linux-amd64";
      hash = "sha256-Y6DfvMZKgMR1MWfs4i9r+wirQRKPGnlYwzWWuUxLHv8=";
    };
    "aarch64-linux" = {
      name = "linux-arm64";
      hash = "sha256-BkRnAIPjQbgklV960Rku4exk3p3V/rv0AaofdhXfepc=";
    };
    "x86_64-darwin" = {
      name = "darwin-amd64";
      hash = "sha256-I4EG6T//+YFLOlQMpW1ERpBzR/882lXMPqpO7em/QJY=";
    };
    "aarch64-darwin" = {
      name = "darwin-arm64";
      hash = "sha256-QtHCvTgfrQilIbd3S3/zkyBLccukGfFckCrZPCIMNMg=";
    };
  };
  platform = systemToPlatform.${system} or throwSystem;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gh-models";
  version = "0.0.6";

  src = fetchurl {
    name = "gh-models";
    url = "https://github.com/github/gh-models/releases/download/v${finalAttrs.version}/${platform.name}";
    hash = platform.hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -m755 -D $src $out/bin/gh-models

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/github/gh-models/releases/tag/v${finalAttrs.version}";
    description = "CLI extension for the GitHub Models service";
    homepage = "https://github.com/github/gh-models";
    license = lib.licenses.mit;
    mainProgram = "gh-models";
    maintainers = with lib.maintainers; [ wenjinnn ];
    platforms = lib.attrNames systemToPlatform;
  };
})
