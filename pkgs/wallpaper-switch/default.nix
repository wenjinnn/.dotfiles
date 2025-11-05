{
  runCommand,
  lib,
  makeWrapper,
  swaybg,
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
            swaybg
            gawk
            findutils
            coreutils-full
            bash
          ]
        }
  ''
