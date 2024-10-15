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
    nautilus = prev.nautilus.overrideAttrs (nsuper: {
      buildInputs =
        nsuper.buildInputs
        ++ (with prev.gst_all_1; [
          gst-plugins-good
          gst-plugins-bad
        ]);
    });
    ags = prev.ags.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "wenjinnn";
        repo = "ags";
        rev = "08043a95130f674b621370260bc153769e167d2e";
        hash = "sha256-8fhWCcixq0lR/AhZG/U8Kcw6UPOMxM571WiQ2demcoE=";
        fetchSubmodules = true;
      };
      buildInputs =
        old.buildInputs
        ++ (with prev.pkgs; [
          accountsservice
          gtk3
          libdbusmenu-gtk3
          gvfs
          libnotify
          pam
        ]);
    });
    ags-greeter = final.callPackage ./ags-greeter {};
    # IM support patch
    swappy = prev.swappy.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "jtheoof";
        repo = "swappy";
        rev = "c8518bf9b99410edf8d64f21994aabb12ca14d42";
        hash = "sha256-tKLtdRpGZmIizBQE59rCjDwyxBL+FKV+mOIZMmdu5c8=";
      };
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     system = final.system;
  #     config.allowUnfree = true;
  #     overlays = [modifications];
  #   };
  # };
}
