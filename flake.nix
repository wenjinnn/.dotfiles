{
  description = "NixOS Flake and Home Manager configuration of wenjin";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # will be appended to the system-level substituters
    extra-substituters = [
      # nix community's cache server
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://wenjinnn.cachix.org"
    ];

    # will be appended to the system-level trusted-public-keys
    extra-trusted-public-keys = [
      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "wenjinnn.cachix.org-1:g4YUsgvT21EYKUP4n9p677m5SwJ85gX3NSi+P5wyFKg="
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

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-on-droid.url = "github:nix-community/nix-on-droid/release-23.11";
    # follow `main` branch of this repository, considered being stable
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-on-droid,
      nixos-hardware,
      nur,
      sops-nix,
      stylix,
      nix-index-database,
      nixos-raspberrypi,
      disko,
      ...
    }@inputs:
    let
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
      me = {
        username = "wenjin";
        mail = {
          outlook = "hewenjin94@outlook.com";
          gmail = "hewenjin1112@gmail.com";
        };
      };
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
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
          specialArgs = { inherit inputs outputs me; };
          modules = [
            # > Our main nixos configuration file <
            ./nixos/hosts/nixos
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen
            nur.modules.nixos.default
            sops-nix.nixosModules.sops
            stylix.nixosModules.stylix
            nix-index-database.nixosModules.nix-index
            # for eGPU
            nixos-hardware.nixosModules.common-gpu-amd
          ];
        };
        nixos-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs me; };
          modules = [
            ./nixos/hosts/nixos-wsl
            nur.modules.nixos.default
            sops-nix.nixosModules.sops
            stylix.nixosModules.stylix
            nix-index-database.nixosModules.nix-index
          ];
        };
        aws = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs me; };
          modules = [
            ./nixos/hosts/aws
          ];
        };
        aliyun = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs me; };
          modules = [
            disko.nixosModules.disko
            ./nixos/hosts/aliyun
          ];
        };
        rpi5 = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit
              inputs
              outputs
              me
              nixos-raspberrypi
              ;
          };
          modules = [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.page-size-16k
                raspberry-pi-5.display-vc4
                raspberry-pi-5.bluetooth
                usb-gadget-ethernet
                trusted-nix-caches
                nixpkgs-rpi
                disko.nixosModules.disko
                sops-nix.nixosModules.sops
                ./nixos/hosts/rpi5/configuration.nix
              ];
            }
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
        extraSpecialArgs = {
          username = "nix-on-droid";
        };

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
          extraSpecialArgs = {
            inherit inputs outputs me;
            mainMonitor = "eDP-1";
          };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/home.nix
            ./home-manager/hosts/nixos.nix
            nur.modules.homeManager.default
            stylix.homeModules.stylix
            nix-index-database.homeModules.nix-index
          ];
        };
        "wenjin@nixos-wsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs me; };
          modules = [
            # > Our main home-manager configuration file <
            ./home-manager/home.nix
            nur.modules.homeManager.default
            stylix.homeModules.stylix
            nix-index-database.homeModules.nix-index
          ];
        };
      };
    };
}
