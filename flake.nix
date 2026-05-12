{
  description = "nixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
    browseros-ai = {
        url = "github:skifli/browseros-ai"; # Run nix store prefetch-file \
        inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # Managing files and configs in each users' home directory
    lan-mouse.url = "github:feschber/lan-mouse";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # System wide theming
    way-edges = {
      url = "github:way-edges/way-edges";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    /*
      winapps = {
        url = "github:winapps-org/winapps";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    */
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    
    vicinae.url = "github:vicinaehq/vicinae"; # Following nixpkgs makes cache miss
    anki-mcp.url = "github:ankimcp/anki-mcp-server-addon";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
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
            pkgsUnstable = import nixpkgs-unstable {
              inherit system;
            };

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
        lyra = {
          system = "x86_64-linux";
          builder = mkHost;
        };
      };
    in
    {
      # Automatically generate nixosConfigurations from hosts list
      nixosConfigurations = builtins.mapAttrs (hostname: cfg: cfg.builder hostname cfg.system) hosts;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
