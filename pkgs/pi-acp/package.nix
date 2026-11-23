{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  nodejs-slim,
}:
let
  version = "0.0.35";
in
buildNpmPackage rec {
  pname = "pi-acp";
  inherit version;

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v${version}";
    hash = "sha256-/5ga4YEi5GZ95ru+9gDpXp9iWVqmLeInIHddskO4uXg=";
  };

  npmDepsHash = "sha256-BtLtlL0zpoOzN094Wf9GZrpfQm4eVpcITzMxfEeMpKI=";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs ];

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/pi-acp
    cp -r dist node_modules package.json $out/lib/node_modules/pi-acp/

    mkdir -p $out/bin
    makeWrapper ${nodejs-slim}/bin/node $out/bin/pi-acp \
      --add-flags "$out/lib/node_modules/pi-acp/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "ACP adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = licenses.mit;
    mainProgram = "pi-acp";
    platforms = platforms.all;
  };
}
