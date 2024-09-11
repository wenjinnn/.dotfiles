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
    foot = prev.foot.overrideAttrs (old: {
      src = prev.fetchFromGitea {
        domain = "codeberg.org";
        owner = "queezle";
        repo = "foot";
        rev = "70a3c2f505de128b32d725bbe87306a4f7b1e9cb";
        hash = "sha256-74R4aVv+mK4vxsh8l1OoAE02w/KgeYA7cdRWG1paYpU=";
      };
      mesonFlags =
        old.mesonFlags
        ++ [
          "-Dext-underline=true"
        ];
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
