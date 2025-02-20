# This file defines overlays
{ inputs, ... }:
let
  electron-flags = [
    "--password-store=gnome-libsecret"
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
    "--enable-wayland-ime"
  ];
in
rec {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

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
    # rss2email from main branch that support lmtp feature
    rss2email = prev.rss2email.overrideAttrs (old: {
      src = prev.pkgs.fetchFromGitHub {
        owner = "rss2email";
        repo = "rss2email";
        rev = "0efe6c299b4e9f2545455d6bc6b6c2753cff1440";
        hash = "sha256-QuNRXtKDEx20On4dyCgJ6yGSI0WSxdwr/IuzD35JzVQ=";
      };
      patches = null;
      installCheckPhase = null;
    });
    # fix scan not work
    rofi-bluetooth = prev.rofi-bluetooth.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "alyraffauf";
        repo = "rofi-bluetooth";
        rev = "50252e4a9aebe4899a6ef2f7bc11d91b7e4aa8ae";
        hash = "sha256-o0Sr3/888L/2KzZZP/EcXx+8ZUzdHB/I/VIeVuJvJks=";
      };
    });
    # use rofi wayland
    rofi-pulse-select = prev.rofi-pulse-select.override {
      rofi-unwrapped = prev.pkgs.rofi-wayland-unwrapped;
    };
    # use rofi wayland
    rofi-systemd = prev.rofi-systemd.override {
      rofi = prev.pkgs.rofi-wayland;
    };
    # use rofi wayland
    rofimoji = prev.rofimoji.override {
      rofi = prev.pkgs.rofi-wayland;
    };
    pass = prev.pass.override {
      waylandSupport = true;
    };
    rofi-pass-wayland = prev.rofi-pass-wayland.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "wenjinnn";
        repo = "rofi-pass";
        rev = "3cf83dc03e0b3018ba1636cbbcbd6a194f4873e5";
        hash = "sha256-Vt5aGhb79G7gLcVOJKaEodC4gnXiSzxc97imttdUcMU=";
      };
    });
    # IM support patch
    swappy = prev.swappy.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "jtheoof";
        repo = "swappy";
        rev = "fca4f6dcdb05c78ad63a0924412a4ef3345484a0";
        hash = "sha256-gwlUklfr/NA7JIkB9YloS9f8+3h5y3rSs3ISeVXAPZk=";
      };
    });
    sonarlint-vscode = prev.vscode-utils.extensionFromVscodeMarketplace {
      name = "sonarlint-vscode";
      publisher = "sonarsource";
      version = "4.16.0";
      sha256 = "sha256-dhRdLvnZlcNS8ruVIoBQhnJ1gL2yWzpEXFaGN8JRZUQ=";
    };
    spring-boot-tools = prev.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscode-spring-boot";
      publisher = "vmware";
      version = "1.61.2025022000";
      sha256 = "sha256-auv8CtLgLmzo9V72qF4AWno32+9cdiiQvctQz2d/Wlg=";
    };
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
