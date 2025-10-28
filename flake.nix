{
  description = "nixOS + Home Manager configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://cachix.cachix.org"
      "https://niri.cachix.org/"
      "https://nix-community.cachix.org/"
      "https://vicinae.cachix.org"
      # "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      # "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # Managing files and configs in each users' home directory
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # System wide theming
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae"; # Following nixpkgs makes cache miss
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs: # Captures all inputs into a variable
    let
      # Helper function to generate attributes for all systems in the list
      mkHost =
        # Pass host and system into the function
        hostname: system:
        nixpkgs.lib.nixosSystem {
          # Import required modules
          modules = [
            ./hosts/${hostname}/configuration.nix
          ];
          # Attribute set of extra arguments passed to Nix module functions
          specialArgs = {
            inherit
              self
              inputs

              hostname
              system
              ;
          };
        };
      # Define the hosts and their respective architecture
      hosts = {
        lyra = "x86_64-linux";
        pifi = "aarch64-linux";
      };
    in
    {
      # Automatically generate nixosConfigurations from hosts list
      nixosConfigurations = builtins.mapAttrs mkHost hosts;
    };
}
