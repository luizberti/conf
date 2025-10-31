{
  description = "General Purpose Configuration for macOS and NixOS";

  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    agenix.url = "github:ryantm/agenix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      # url = "https://flakehub.com/f/nix-darwin/nix-darwin/0"; # Stable nix-darwin (use 0.1 for unstable)
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # HOMEBREW + TAPS
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    agenix,
    darwin,
    determinate,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    home-manager,
    disko,
  } @ inputs: let
    user = "luizberti";
    name = "Luiz Berti";

    platforms = {
      macos = ["aarch64-darwin"];
      linux = ["x86_64-linux" "aarch64-linux"];
      every = f: nixpkgs.lib.genAttrs (platforms.linux ++ platforms.macos) f;
    };
  in {
    devShells = platforms.every (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = with pkgs;
        mkShellNoCC {
          nativeBuildInputs = with pkgs; [fish neovim git age age-plugin-yubikey];
          shellHook = ''
            export EDITOR=nvim
            exec fish
          '';
        };
    });

    darwinConfigurations.ares = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = inputs // {inherit user;};
      modules = [
        determinate.darwinModules.default
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            inherit user;
            enable = true;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
            mutableTaps = false;
            autoMigrate = true;
          };
        }

        ./hosts/ares.nix
      ];
    };

    nixosConfigurations.hades = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs // {inherit user;};
      modules = [
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = import ./modules/nixos/home-manager.nix;
          };
        }
        ./hosts/nixos/hades
      ];
    };

    formatter = platforms.every (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
  };
}
