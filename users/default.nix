{
  commonHostVars,
  inputs,
  pkgs,
  usersVars,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # https://mynixos.com/home-manager/option/xdg.portal.enable
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  home-manager = {
    backupFileExtension = "hm-backup";
    # overwriteBackup = true;

    useGlobalPkgs = false; # Stylix HM module sets nixpkgs overlays; avoid warnings by letting HM manage its own pkgs
    useUserPackages = true; # Make packages not available system-wide, instead in ~/.nix-profile
    # extraSpecialArgs = { inherit commonHostVars hostVars; }; # Home manager WHY do you use this ;-;

    users =
      builtins.mapAttrs (username: userVars: {
        programs.home-manager.enable = true; # Let Home Manager install and manage itself.

        xdg = {
          configFile."mimeapps.list".force = true;

          enable = true; # Ensures ENV variables are set up so apps follow the XDG Base Dir Spec

          /*
             Disabled due to https://cashmere.rs/blog/20250612002456-how-to-fix-screensharing-for-niri-wm-under-nixos#solution
          portal = {
            enable = true;

            # https://mynixos.com/home-manager/option/xdg.portal.xdgOpenUsePortal
            xdgOpenUsePortal = true;

            config.common = {
              default = [
                "luminous"
                "kde"
              ];
            };

            extraPortals = with pkgs; [
              xdg-desktop-portal-luminous
              kdePackages.xdg-desktop-portal-kde
              # xdg-desktop-portal-luminous
            ];
          };
          */

          mimeApps.enable = true;
          userDirs = {
            enable = true;
            createDirectories = true;
          };
        };

        home = {
          sessionPath = [
            "/home/${userVars.username}/.cargo/bin"
          ];

          sessionVariables = let
            primaryBrowser = builtins.elemAt userVars.programs.browsers 0;
          in {
            BROWSER = pkgs.lib.mkForce primaryBrowser;
            EDITOR = userVars.programs.editor;
            SHELL = userVars.programs.shell;
            TERM = userVars.programs.terminal;
            VISUAL = userVars.programs.visual;
          };

          shellAliases =
            {
              # --- OGs ---
              sup = "sudo -E";
              nfu = "nix flake update";
              nhsw = "nh os switch . --accept-flake-config -H";
              nisw = "sudo nixos-rebuild switch --flake .#";
              nunh = "nix flake update && nh os switch . --accept-flake-config -H";
              nuni = "nix flake update && sudo nixos-rebuild switch --flake .#";

              # --- Testing & Dry Runs ---
              nhtest = "nh os test . --accept-flake-config -H"; # Apply immediately, revert on reboot
              nhdry = "nh os switch . --dry --accept-flake-config -H"; # See what WOULD happen
              nhask = "nh os switch . --ask --accept-flake-config -H"; # Ask for confirmation after diff

              # --- VM Prototyping (Sandbox) ---
              # Standard rebuild VM command
              nivm = "nixos-rebuild build-vm --flake .#";
              # nh equivalent (available in newer versions)
              nhvm = "nh os build-vm . --accept-flake-config -H";

              # --- Comparison & Cleanup ---
              # Quick diff between current system and a potential build
              nhdiff = "nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel --dry-run && nvd diff /run/current-system ./result";
            }
            // commonHostVars.shellAliases;

          inherit username;
          homeDirectory = "/home/${username}";

          file.".local/share/wallpaper" = let
            asset = ./${username}/assets/wallpapers/${userVars.wallpaper};
          in
            pkgs.lib.mkIf (builtins.pathExists asset) {
              source = asset;
            };

          file = {
            ".local/bin" = {
              source = ./${userVars.username}/scripts;
              recursive = true;
            };
          };

          xdg.userDirs.setSessionVariables = false;

          stateVersion = "25.05"; # DO NOT CHANGE!
        };
      })
      usersVars; # For each user
  };

  xdg = {
    # enable = true; # Ensures ENV variables are set up so apps follow the XDG Base Dir Spec
    terminal-exec.enable = true; # https://discourse.nixos.org/t/how-to-set-default-terminal-for-desktop-entries/69190/4

    portal = {
      enable = true; # ABSOLUTE DINGLEBERRY

      # https://mynixos.com/nixpkgs/option/xdg.portal.xdgOpenUsePortal
      xdgOpenUsePortal = true;

      config = {
        common = {
          default = [
            "kde"
          ];
        };

        # https://cashmere.rs/blog/20250612002456-how-to-fix-screensharing-for-niri-wm-under-nixos/
        niri = {
          default = [
            "kde"
            "wlr"
          ];

          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        };
      };

      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-wlr
      ];
    };

    mime.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd

    xdg-utils

    xdg-desktop-portal
    xdg-desktop-portal-wlr
    kdePackages.xdg-desktop-portal-kde
  ];
}
