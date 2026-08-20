{
  commonHostVars,
  hostVars,
  inputs,
  pkgs,
  usersVars,
  ...
}: let
  /*
  Aug 11 14:48:41 lyra systemd[2123]: Starting Xdg Desktop Portal For KDE...
  Aug 11 14:48:41 lyra systemd[2123]: Started Xdg Desktop Portal For KDE.
  Aug 11 14:48:41 lyra xdg-desktop-portal-kde[18916]: QQmlApplicationEngine failed to load component
  Aug 11 14:48:41 lyra xdg-desktop-portal-kde[18916]: qrc:/qt/qml/org/kde/xdgdesktopportal/AppChooserDialog.qml: module "kvantum" is not installed
  Aug 11 14:48:43 lyra systemd-coredump[18922]: [🡕] Process 18916 (.xdg-desktop-po) of user 1000 dumped core.
  */
  xdg-desktop-portal-kde = pkgs.symlinkJoin {
    name = "xdg-desktop-portal-kde-wrapped";
    paths = [pkgs.kdePackages.xdg-desktop-portal-kde];
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      wrapProgram $out/libexec/xdg-desktop-portal-kde \
        --prefix QML2_IMPORT_PATH : "${pkgs.kdePackages.qtstyleplugin-kvantum}/lib/qt-6/qml"
    '';
  };
in {
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

    useGlobalPkgs = true; # Stylix HM module sets nixpkgs overlays; avoid warnings by letting HM manage its own pkgs. However now set to true for speed heehee
    useUserPackages = true; # Make packages not available system-wide, instead in ~/.nix-profile
    # extraSpecialArgs = { inherit commonHostVars hostVars; }; # Home manager WHY do you use this ;-;

    users =
      builtins.mapAttrs (username: userVars: {
        programs.home-manager.enable = true; # Let Home Manager install and manage itself.

        systemd.user.services = userVars.systemdServices;
        systemd.user.timers = userVars.systemdTimers;

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
          in
            {
              BROWSER = pkgs.lib.mkForce primaryBrowser;
              EDITOR = userVars.programs.editor;
              # SHELL = userVars.programs.terminal-shell; # - This and below commented out because can cause problems in SSH
              # TERM = userVars.programs.terminal;
              VISUAL = userVars.programs.visual;
            }
            // userVars.sessionVariables;

          shellAliases =
            {
              # Essentials
              sup = "sudo -E";
              nsw = "nh os switch path:. --accept-flake-config -H ${hostVars.hostname}";
              nup = "nh os switch path:. --update --accept-flake-config -H ${hostVars.hostname}"; # Updates flake inputs & switches

              # Testing & Verification
              ntest = "nh os test path:. --accept-flake-config -H ${hostVars.hostname}"; # Apply temporary (resets on reboot)
              nboot = "nh os boot path:. --accept-flake-config -H ${hostVars.hostname}"; # Apply to next boot only
              ndry = "nh os switch path:. --dry --accept-flake-config -H ${hostVars.hostname}"; # Dry run (shows nvd diff automatically)
              nask = "nh os switch path:. --ask --accept-flake-config -H ${hostVars.hostname}"; # Shows diff & prompts before switching
              nvm = "nh os build-vm path:. --accept-flake-config -H ${hostVars.hostname}"; # Build & run in VM

              nfc = "nix flake check --no-build";

              # Maintenance
              ncl = "nh clean all --keep 5"; # Removes old generations, keeps 5

              # Git & Sync Workflows
              # Sync submodules/git pull, then switch
              zngu = "z nixos; git pull && git submodule update --init --recursive && git log --oneline ORIG_HEAD..HEAD";
              znsw = "z nixos; git pull && git submodule update --init --recursive && nh os switch path:. --accept-flake-config -H ${hostVars.hostname}";
              znup = "z nixos; git pull && git submodule update --init --recursive && nh os switch path:. --update --accept-flake-config -H ${hostVars.hostname}";

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

          file.".local/share/wallpaper-blurred" = let
            blurredAsset = ./${username}/assets/wallpapers/${userVars.wallpaper}-blurred;
          in
            pkgs.lib.mkIf (builtins.pathExists blurredAsset) {
              source = blurredAsset;
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

      # Enable this: https://mynixos.com/nixpkgs/option/xdg.portal.xdgOpenUsePortal
      # Ok, so before this was true. But now after 12/08/2026@18:18 I've set this to false and now xdg-open etc is working. gio worked when this was true but not xdg-open so I assume I broke something. But now this is false xdg-open does also work.
      xdgOpenUsePortal = false;

      config = {
        common = {
          # Use KDE as the default for everything
          default = pkgs.lib.mkForce [
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
          "org.freedesktop.portal.FileChooser" = ["kde"]; # Anytype - [x:x/x.x:ERROR:dbus/object_proxy.cc:572] Failed to call method: org.freedesktop.DBus.Properties.Get: object_path= /org/freedesktop/portal/desktop: org.freedesktop.DBus.Error.InvalidArgs: No such interface “org.freedesktop.portal.FileChooser”

          # Forces Electron/Anytype to read dark/light preferences via GNOME/GTK instead of failing via KDE
          # Try gtk first though before gnome
          "org.freedesktop.impl.portal.Settings" = ["gtk"];

          # Explicitly route URI/link opening through the KDE portal backend
          # Otherwise stuff went kaboom :(
          "org.freedesktop.impl.portal.OpenURI" = ["kde"];
          "org.freedesktop.impl.portal.OpenFile" = ["kde"];
          "org.freedesktop.impl.portal.OpenDirectory" = ["kde"];
        };
      };

      extraPortals = [
        xdg-desktop-portal-kde
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk # Default fallback portal for Niri
      ];
    };

    mime.enable = true;
  };

  # Required to prevent the GNOME portal backend from timing out on startup
  services.dbus.packages = [pkgs.gsettings-desktop-schemas];
  systemd.user.services."xdg-desktop-portal" = {
    after = ["xdg-desktop-portal-gnome.service" "xdg-desktop-portal-kde.service" "xdg-desktop-portal-gtk.service"];
    wants = ["xdg-desktop-portal-gnome.service" "xdg-desktop-portal-kde.service" "xdg-desktop-portal-gtk.service"];
  };

  environment.systemPackages = with pkgs;
    [
      nix-output-monitor
      nvd

      xdg-utils

      xdg-desktop-portal
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk

      # The core Kvantum manager and themes
      libsForQt5.qtstyleplugin-kvantum
      qt6Packages.qtstyleplugin-kvantum
    ]
    ++ [
      xdg-desktop-portal-kde
    ];
}
