{
  description = "nixOS + Home Manager configuration";

  nixConfig = {
    extra-substituters = [
      "https://skifli-nixos.cachix.org"
      "https://cache.nixos.org/"
      "https://cachix.cachix.org"
      # "https://lan-mouse.cachix.org/"
      # "https://niri.cachix.org/" sodiboo's flake
      "https://nix-community.cachix.org/"
      "https://vicinae.cachix.org/"
      "https://nixpkgs-python.cachix.org"
      "https://cache.forall.systems"
      "https://nyx-cache.chaotic.cx/"
      "https://niri-nix.cachix.org"
    ];
    
    extra-trusted-public-keys = [
      "skifli-nixos.cachix.org-1:XfgWwHJkEfjc+66r9CwpWQ30CvI2J+M5D3LpyaN2UN0="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      # "lan-mouse.cachix.org-1:KlE2AEZUgkzNKM7BIzMQo8w9yJYqUpor1CAUNRY6OyM="
      # "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
      "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anki-seara = {
      url = "github:rodrada/seara";
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

    # Switched from sodiboo/niri-flake to BANanaD3V/niri-nix
    # See: https://github.com/niri-wm/niri/pull/4404
    # TODO: Switch back to sodiboo/niri-flake when it gets updated again <3
    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
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
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # concord.url = "github:chojs23/concord";
    # lan-mouse.url = "github:feschber/lan-mouse";
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
            ./lix.nix
            # Below is specifically with stable nixOS - inputs.chaotic.nixosModules.default is IMPORTANT for UNstable - but irrelevant to me
            inputs.chaotic.nixosModules.nyx-cache
            inputs.chaotic.nixosModules.nyx-overlay
            inputs.chaotic.nixosModules.nyx-registry
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
