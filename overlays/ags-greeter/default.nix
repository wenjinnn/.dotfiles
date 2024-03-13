{
  ags,
  writeShellScript,
  wlr-randr,
  bash,
  stdenv,
  cage,
  swww,
  fzf,
  bun,
  dart-sass,
  fd,
  brightnessctl,
  accountsservice,
  slurp,
  wf-recorder,
  wl-clipboard,
  wayshot,
  swappy,
  hyprpicker,
  pavucontrol,
  networkmanager,
  gtk3,
  which,
  hyprland,
  matugen,
}: let
  name = "ags-greeter";
  agsOverride = ags.override {extraPackages = [accountsservice];};

  dependencies = [
    which
    dart-sass
    fd
    brightnessctl
    swww
    agsOverride
    matugen
    fzf
    hyprland
    slurp
    wf-recorder
    wl-clipboard
    wayshot
    swappy
    hyprpicker
    pavucontrol
    networkmanager
    gtk3
  ];

  addBins = list: builtins.concatStringsSep ":" (builtins.map (p: "${p}/bin") list);

  greeter = writeShellScript "greeter" ''
    export PATH=$PATH:${addBins dependencies}
    ${cage}/bin/cage -ds -m last  -- ${bash}/bin/bash -c "${wlr-randr}/bin/wlr-randr --output eDP-1 --scale 2 && ${agsOverride}/bin/ags -c ${config}/greeter.js"
  '';

  desktop = writeShellScript name ''
    export PATH=$PATH:${addBins dependencies}
    ${agsOverride}/bin/ags -b ${name} -c ${config}/config.js $@
  '';

  config = stdenv.mkDerivation {
    inherit name;
    src = ../../xdg/config/ags/.;

    buildPhase = ''
      ${bun}/bin/bun build ./main.ts \
        --outfile main.js \
        --external "resource://*" \
        --external "gi://*"

      ${bun}/bin/bun build ./greeter/greeter.ts \
        --outfile greeter.js \
        --external "resource://*" \
        --external "gi://*"
    '';

    installPhase = ''
      mkdir -p $out
      cp -r assets $out
      cp -r style $out
      cp -r greeter $out
      cp -r widget $out
      cp -f main.js $out/config.js
      cp -f greeter.js $out/greeter.js
    '';
  };
in
  stdenv.mkDerivation {
    inherit name;
    src = config;

    installPhase = ''
      mkdir -p $out/bin
      cp -r . $out
      cp ${desktop} $out/bin/${name}
      cp ${greeter} $out/bin/greeter
    '';
  }
