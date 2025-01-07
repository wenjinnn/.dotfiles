{
  description = "NixOS Flake and Home Manager configuration of wenjin";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # will be appended to the system-level substituters
    extra-substituters = [
      # nix community's cache server
      "https://nix-community.cachix.org"
    ];

    # will be appended to the system-level trusted-public-keys
    extra-trusted-public-keys = [
      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    nixos-wsl = {
      url = "github:/nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-on-droid,
    nixos-hardware,
    nur,
    sops-nix,
    stylix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      #"aarch64-linux"
      #"i686-linux"
      "x86_64-linux"
      #"aarch64-darwin"
      #"x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
    username = "wenjin";
    outlook = "hewenjin94@outlook.com";
    gmail = "hewenjin1112@gmail.com";
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs username outlook gmail;};
        modules = [
          # > Our main nixos configuration file <
          ./nixos/configuration.nix
          ./nixos/hosts/nixos
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
          nur.modules.nixos.default
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
        ];
      };
      nixos-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs username outlook gmail;};
        modules = [
          ./nixos/configuration.nix
          ./nixos/hosts/nixos-wsl
          nur.modules.nixos.default
          sops-nix.nixosModules.sops
        ];
      };
    };

    # Available through 'nix-on-droid switch --flake path/to/flake#device'
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [
        ./nixos/hosts/nix-on-droid

        # list of extra modules for Nix-on-Droid system
        # { nix.registry.nixpkgs.flake = nixpkgs; }
        # ./path/to/module.nix

        # or import source out-of-tree modules like:
        # flake.nixOnDroidModules.module
      ];

      # list of extra special args for Nix-on-Droid modules
      extraSpecialArgs = {username = "nix-on-droid";};

      # set nixpkgs instance, it is recommended to apply `nix-on-droid.overlays.default`
      pkgs = import nixpkgs {
        system = "aarch64-linux";

        overlays = [
          nix-on-droid.overlays.default
          # add other overlays
        ];
      };
      # set path to home-manager flake
      home-manager-path = home-manager.outPath;
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "wenjin@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs username outlook gmail;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/home.nix
          ./home-manager/hosts/nixos.nix
          nur.modules.homeManager.default
          stylix.homeManagerModules.stylix
        ];
      };
      "wenjin@nixos-wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs username outlook gmail;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-manager/home.nix
        ];
      };
    };
  };
}
