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
    vscode-java-debug = prev.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscode-java-debug";
      publisher = "vscjava";
      version = "0.58.2026012907";
      sha256 = "sha256-fukRuQe29GHeia+IdkXrrCU/6qusa3smF8AVs7SSb88=";
    };
    vscode-java-test = prev.vscode-utils.extensionFromVscodeMarketplace {
      name = "vscode-java-test";
      publisher = "vscjava";
      version = "0.44.2026030602";
      sha256 = "sha256-hPgDdPx3nrL9abQmmTuWt5gzerItID6iiLkjve92DFs=";
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
