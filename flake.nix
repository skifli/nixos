{
  description = "nixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
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
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    }; # Managing files and configs in each users' home directory
    ironbar.url = "github:JakeStanger/ironbar";
    lan-mouse.url = "github:feschber/lan-mouse";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
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

    affinity-nix.url = "github:mrshmllow/affinity-nix";
    # anki-mcp.url = "github:ankimcp/anki-mcp-server-addon";
    vicinae.url = "github:vicinaehq/vicinae"; # Following nixpkgs makes cache miss
    vicinae-extensions.url = "github:vicinaehq/extensions";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs:
  # Captures all inputs into a variable
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

    systems = nixpkgs.lib.unique ((map (cfg: cfg.system) (builtins.attrValues hosts)) ++ ["aarch64-linux"]);
    hostsForSystem = system: builtins.attrNames (nixpkgs.lib.filterAttrs (_: cfg: cfg.system == system) hosts);
  in {
    # Automatically generate nixosConfigurations from hosts list
    nixosConfigurations = builtins.mapAttrs (hostname: cfg: cfg.builder hostname cfg.system) hosts;

    checks = nixpkgs.lib.genAttrs systems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        builtins.listToAttrs (
          map (
            hostname: {
              name = "eval-${hostname}";
              value = pkgs.runCommand "eval-${hostname}" {} ''
                echo "${self.nixosConfigurations.${hostname}.config.system.build.toplevel.drvPath}" > "$out"
              '';
            }
          ) (hostsForSystem system)
        )
    );

    devShells = nixpkgs.lib.genAttrs systems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            pre-commit
            alejandra
            statix
            deadnix
          ];

          shellHook = ''
            if [ -d .git ]; then
              pre-commit install --install-hooks >/dev/null 2>&1 || true
            fi
          '';
        };
      }
    );

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
  };
}
