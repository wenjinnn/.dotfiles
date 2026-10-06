{
  lib,
  makeWrapper,
  python3Packages,
  stdenvNoCC,
}:

let
  python = python3Packages.python.withPackages (
    ps: with ps; [
      bleak
      gattlib
    ]
  );
in
stdenvNoCC.mkDerivation {
  pname = "reef-roll-filter-ble-gateway";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ${python}/bin/python tests/test_reef_roll_filter_ble_gateway.py
    runHook postCheck
  '';

  installPhase = ''
    install -Dm644 src/reef_roll_filter_ble_gateway.py $out/libexec/reef-roll-filter-ble-gateway.py
    makeWrapper ${python}/bin/python $out/bin/reef-roll-filter-ble-gateway \
      --add-flags "$out/libexec/reef-roll-filter-ble-gateway.py"
  '';

  meta = {
    description = "Restore a reef paper-reel filter to a configured BLE mode";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
