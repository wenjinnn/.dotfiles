# This file defines overlays
{inputs, ...}: let
  electron-flags = [
    "--password-store=gnome-libsecret"
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
    "--enable-wayland-ime"
  ];
in rec {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    microsoft-edge = prev.microsoft-edge.override {
      commandLineArgs = electron-flags;
    };
    vscode = prev.vscode.override {
      commandLineArgs = electron-flags;
    };
    electron = prev.electron.override {
      commandLineArgs = electron-flags;
    };
    gnome = prev.gnome.overrideScope' (gself: gsuper: {
      nautilus = gsuper.nautilus.overrideAttrs (nsuper: {
        buildInputs =
          nsuper.buildInputs
          ++ (with prev.gst_all_1; [
            gst-plugins-good
            gst-plugins-bad
          ]);
      });
    });
    matugen = inputs.matugen.packages.${final.system}.default;
    ags = inputs.ags.packages.${final.system}.default;
    hyprlock = (inputs.hyprlock.packages.${final.system}.default.override {mesa = final.mesa;});
    ags-greeter = final.callPackage ./ags-greeter {};
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
      overlays = [modifications];
    };
  };
}
