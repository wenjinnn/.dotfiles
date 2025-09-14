# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
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
        rev = "9e985706bb13616d0333cd71eae5b03dc7388af6";
        hash = "sha256-DrTV+RRhhf6bzKSwZMbg1bm6U3SpqDS7lK6yIKOkaZo=";
      };
      patches = null;
      installCheckPhase = null;
      doCheck = false;
      dontUseUnittestCheck = true;

    });
    python3Packages = prev.python3Packages.override {
      overrides = self: super: {
        feedparser = super.feedparser.overrideAttrs (oldAttrs: {
          src = prev.pkgs.fetchFromGitHub {
            owner = "kurtmckee";
            repo = "feedparser";
            rev = "74a0bf49bf640c1e09a7f71a17720a0635f12f53";
            hash = "sha256-3hwZOAh/fb5mzRlwcoVk6bzdnnkOCcwEct1cMLlAX1A=";
          };
          propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [
            super.poetry-core
            super.requests
          ];
          installCheckPhase = null;
        });
      };
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
