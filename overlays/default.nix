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
    microsoft-edge = prev.microsoft-edge.overrideAttrs (old: let
      baseName = "microsoft-edge";
      channel = "stable";
      version = "128.0.2739.67";
      revision = "1";
    in {
      src = prev.fetchurl {
        url = "https://packages.microsoft.com/repos/edge/pool/main/m/${baseName}-${channel}/${baseName}-${channel}_${version}-${revision}_amd64.deb";
        hash = "sha256-Y8PxyAibuEhwKJpqnhtBy1F2Kn+ONw6NVtC25R+fFVo=";
      };
    });
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
    # fix hyprland switch workspace event error patch
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
    # rename astal to ags greeter
    ags-greeter = final.callPackage ./ags-greeter {};
    # IM support patch
    swappy = prev.swappy.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "jtheoof";
        repo = "swappy";
        rev = "fca4f6dcdb05c78ad63a0924412a4ef3345484a0";
        hash = "sha256-gwlUklfr/NA7JIkB9YloS9f8+3h5y3rSs3ISeVXAPZk=";
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
