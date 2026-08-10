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

  environment.localBinInPath = true; # Add ~/.local/bin to PATH - used for user scripts dir below

  home-manager = {
    backupFileExtension = "hm-backup";
    overwriteBackup = true;

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
            setSessionVariables = false;
          };
        };

        home = {
          sessionPath = [
            "/home/${userVars.username}/.cargo/bin" # Unfortunately this was from the init commit https://github.com/skifli/nixos/blame/e9317baa1ca7e8abd4e68b59e82ed215199f3dfa/users/default.nix#L68 so I have no idea what this is needed for... well, if it works, don't touch it :p!
            "/home/${userVars.username}/.local/bin" # Idk... I've enabled environment.localBinInPath above, but that didn't really seem to work?
          ];

          # Use pkgs.writeShellScriptBin on each of userVars.shellScripts
          packages = builtins.attrValues (
            builtins.mapAttrs (name: script: pkgs.writeShellScriptBin name script) userVars.shellScripts # Idea stolen from https://github.com/MangoCubes/nix/blob/e7fdb3fe51a8dce3c6ce6bc2a9fe8423f276f187/desktop/packages/home/niri.nix#L11
          );

          sessionVariables = let
            primaryBrowser = builtins.elemAt userVars.programs.browsers 0;
          in {
            BROWSER = pkgs.lib.mkForce primaryBrowser;
            EDITOR = userVars.programs.editor;
            # SHELL = userVars.programs.terminal-shell; # - This and below commented out because can cause problems in SSH
            # TERM = userVars.programs.terminal;
            VISUAL = userVars.programs.visual;
          };

          shellAliases =
            {
              # --- OGs ---
              sup = "sudo -E";
              nfu = "nix flake update";
              nhsw = "nh os switch path:. --accept-flake-config -H";
              nisw = "sudo nixos-rebuild switch --flake"; # Needs path:.#
              nunh = "nix flake update && nh os switch path:. --accept-flake-config -H";
              nuni = "nix flake update && sudo nixos-rebuild switch --flake"; # Needs path:.#

              # --- Testing & Dry Runs ---
              nhtest = "nh os test path:. --accept-flake-config -H"; # Apply immediately, revert on reboot
              nhdry = "nh os switch path:. --dry --accept-flake-config -H"; # See what WOULD happen
              nhask = "nh os switch path:. --ask --accept-flake-config -H"; # Ask for confirmation after diff

              # --- VM Prototyping (Sandbox) ---
              # Standard rebuild VM command
              nivm = "nixos-rebuild build-vm --flake"; # Needs path:.#
              # nh equivalent (available in newer versions)
              nhvm = "nh os build-vm path:. --accept-flake-config -H";

              # --- Comparison & Cleanup ---
              # Quick diff between current system and a potential build
              nhdiff = "nix build path:.#nixosConfigurations.\${hostname}.config.system.build.toplevel --dry-run && nvd diff /run/current-system ./result";

              # --- Actual useful ones ---
              # If already in the dir zoxide errors so use ; not && to continue even if zoxide fails
              zngp = "z nixos; git pull";
              zngs = "z nixos; git submodule update --init --recursive";
              zngu = "z nixos; git pull && git submodule update --init --recursive";
              znnisw = "z nixos; sudo nixos-rebuild switch --flake"; # Needs path:.#
              znguns = "z nixos; git pull && git submodule update --init --recursive && sudo nixos-rebuild switch --flake"; # Needs path:.#

              gfu = "git add . && git commit -m 'feat(flake.lock): update' && git pull && git push";
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
              executable = true; # For scripts!
            };

            ".local/share/misc" = {
              source = ./${userVars.username}/assets/misc;
            };
          };

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
          # Use KDE as the default for everything
          default = [
            "kde"
          ];
        };

        # https://cashmere.rs/blog/20250612002456-how-to-fix-screensharing-for-niri-wm-under-nixos/
        niri = {
          default = pkgs.lib.mkForce [
            "kde"
          ];

          # Niri requires the gnome portal engine specifically for ScreenCast hooks.
          # This will NOT install the GNOME desktop, only a tiny backend daemon.
          # Niri requires xdg-desktop-portal-gnome to be installed for this to work, which is done below in extraPortals.
          # https://github.com/niri-wm/niri/wiki/Screencasting#overview
          "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];

          # Explicitly tell Niri to route Secret Management requests to GNOME Keyring
          "org.freedesktop.impl.portal.Secret" = ["gnome"];

          # Juust in case - https://github.com/niri-wm/niri/wiki/Important-Software#:~:text=If%20you%20do%20not%20want%20to%20install%20nautilus%20%28say%20you%20use%20nemo%20instead%29%2C%20you%20can%20set%20org%2Efreedesktop%2Eimpl%2Eportal%2EFileChooser%3Dgtk%3B%20in%20niri%2Dportals%2Econf%20to%20use%20the%20GTK%20portal%20for%20file%20chooser%20dialogues
          "org.freedesktop.impl.portal.FileChooser" = ["kde"];
        };
      };

      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk # Default fallback portal for Niri
      ];
    };

    mime.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd

    xdg-utils

    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    kdePackages.xdg-desktop-portal-kde
  ];
}
