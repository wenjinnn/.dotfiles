{
  runCommand,
  lib,
  makeWrapper,
  noctalia,
  gawk,
  bash,
  coreutils-full,
  findutils,
}:
runCommand "wallpaper-switch"
  {
    nativeBuildInputs = [ makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    dest="$out/bin/wallpaper-switch"
    cp ${./wallpaper-switch.sh} $dest
    chmod +x $dest
    patchShebangs $dest

      wrapProgram $dest \
        --prefix PATH : ${
          lib.makeBinPath [
            noctalia
            gawk
            findutils
            coreutils-full
            bash
          ]
        }
  ''
