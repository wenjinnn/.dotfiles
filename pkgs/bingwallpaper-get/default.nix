{
  runCommand,
  lib,
  makeWrapper,
  wallpaper-switch,
  jq,
  wget,
  coreutils-full,
  gnused,
}:
runCommand "bingwallpaper-get"
  {
    nativeBuildInputs = [ makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    dest="$out/bin/bingwallpaper-get"
    cp ${./bingwallpaper-get.sh} $dest
    chmod +x $dest
    patchShebangs $dest

      wrapProgram $dest \
        --prefix PATH : ${
          lib.makeBinPath [
            jq
            wget
            gnused
            coreutils-full
            wallpaper-switch
          ]
        }
  ''
