{ runCommandNoCC
, lib
, makeWrapper
, hyprland
, gawk
, swww
, bash
, coreutils-full
, findutils
}: runCommandNoCC "swww-switch" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin
  dest="$out/bin/swww-switch"
  cp ${./swww-switch.sh} $dest
  chmod +x $dest
  patchShebangs $dest

  wrapProgram $dest \
    --prefix PATH : ${lib.makeBinPath [ hyprland swww gawk findutils coreutils-full bash ]}
''
