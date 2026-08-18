{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  userVars,
  inputs,
  ...
}: let
  /*
  ADW_DISABLE_PORTAL vs a11y/interface/high-contrast = true...
  ...the battle to make Anytype dark when the rest of my system is dark :sob:

  12/08/2026@21:45 - The latter makes Zen Browser have like accessibility highlights and stuff which are of course useful to those who need it but I realised it's from this (tested it and confirmed) so I'm disabling this setting for good... hopefully somehow Anytype just... follows the rest of my system??? :sob:
  13/08/2026@13:31 - Finally fixed for good - Anytype switches to system theme when it changes without a restart! I THINK (not 100% sure) it was linked to this commit - https://github.com/skifli/nixos/commit/4ec0c216570e677e6ec6d5a4d1d1d083e7dceb2a. Specifically, setting `org.freedesktop.impl.portal.Settings` to just `gtk`. At least this charade is all over now, phew!
  13/08/2026@22:22 - It broke again but after a rebuild with ADW_DISABLE_PORTAL=1 it works again??? I didn't know before, I definitely don't know now. Just, if I restart my PC tomorrow, and it's switched - I'll be a happy blob of existence. Anyway this hurts my brain, goodnight :sob:.
  */
  lightGtkConfigRaw = {
    iconTheme.name = commonHostVars.icons.light;
    theme = {
      name = commonHostVars.theme.gtk.lightName;
      package = commonHostVars.theme.gtk.package;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
      gtk-theme-name = commonHostVars.theme.gtk.lightName;
    };
  };
  lightDconfRaw = {
    "org/gnome/desktop/interface" = {
      color-scheme = "default";
      gtk-theme = commonHostVars.theme.gtk.lightName;
    };
    /*
    "org/gnome/desktop/a11y/interface" = {
      high-contrast = false;
    };
    */
  };

  darkGtkConfigRaw = {
    iconTheme.name = commonHostVars.icons.dark;
    theme = {
      name = commonHostVars.theme.gtk.darkName;
      package = commonHostVars.theme.gtk.package;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = commonHostVars.theme.gtk.darkName;
    };
  };
  darkDconfRaw = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = commonHostVars.theme.gtk.darkName;
    };
    /*
    "org/gnome/desktop/a11y/interface" = {
      # For some godforsaken reason this is the only thing that makes Anytype activate its dark mode. NOTHING else that I've set here does! Arggghhh!! At least it works now, but I swear this is going to cause some adverse affects later that will take me forever to trace back to this damned variable ;-;.
      # Edit 13/08/2026@13:31 - Not true anymore :sob: see first comment block for solution
      high-contrast = true;
    };
    */
  };

  # Custom helper functions for GTK to avoid recursing into derivation sets (pkgs.adw-gtk3)
  applyGtkDefault = cfg: {
    iconTheme.name = lib.mkDefault cfg.iconTheme.name;
    theme = {
      name = lib.mkDefault cfg.theme.name;
      package = lib.mkDefault cfg.theme.package;
    };
    gtk3.extraConfig = lib.mapAttrs (_: lib.mkDefault) cfg.gtk3.extraConfig;
    gtk4.extraConfig = lib.mapAttrs (_: lib.mkDefault) cfg.gtk4.extraConfig;
  };

  applyGtkForce = cfg: {
    iconTheme.name = lib.mkForce cfg.iconTheme.name;
    theme = {
      name = lib.mkForce cfg.theme.name;
      package = lib.mkForce cfg.theme.package;
    };
    gtk3.extraConfig = lib.mapAttrs (_: lib.mkForce) cfg.gtk3.extraConfig;
    gtk4.extraConfig = lib.mapAttrs (_: lib.mkForce) cfg.gtk4.extraConfig;
  };

  applyDconfDefault = lib.mapAttrsRecursive (_: lib.mkDefault);
  applyDconfForce = lib.mapAttrsRecursive (_: lib.mkForce);
in {
  environment.systemPackages = with pkgs; [
    # For debugging
    glib
  ];

  # Enable Qt styling and set the platform theme platform
  qt = {
    enable = true;
    platformTheme = commonHostVars.theme.qt.platform; # Automatically sets QT_QPA_PLATFORMTHEME which without means Dolphin in dark mode is funky with black text on a black bg...
  };

  home-manager.users.${userVars.username} = {lib, ...}: {
    # Force auto-theme-check to restart after every HM activation/rebuild because it didn't before and since we always rebuild into light if we don't do this this can cause some theme mismatches.
    home.activation.triggerThemeCheck = lib.hm.dag.entryAfter ["reloadSystemd"] ''
      run ${pkgs.systemd}/bin/systemctl --user restart auto-theme-check.service
    '';

    systemd.user.services.auto-theme-check = {
      Unit = {
        Description = "Solar position watcher and theme switcher daemon";
      };
      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";

        Environment = let
          latVal = toString (
            if hostVars.latitude >= 0
            then hostVars.latitude
            else (0 - hostVars.latitude)
          );
          latDir =
            if hostVars.latitude >= 0
            then "N"
            else "S";
          lonVal = toString (
            if hostVars.longitude >= 0
            then hostVars.longitude
            else (0 - hostVars.longitude)
          );
          lonDir =
            if hostVars.longitude >= 0
            then "E"
            else "W";
        in [
          "PATH=/run/wrappers/bin:${lib.makeBinPath [pkgs.libnotify pkgs.coreutils pkgs.bash pkgs.niri pkgs.sunwait]}"
          "USER=${userVars.username}"
          "LAT_VAL=${latVal}"
          "LAT_DIR=${latDir}"
          "LON_VAL=${lonVal}"
          "LON_DIR=${lonDir}"
          "SUNWAIT_BIN=${pkgs.sunwait}/bin/sunwait"
          "SWITCHER_BIN=/home/${userVars.username}/.local/bin/theme-switcher.sh"
          "ICON_PATH=/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg"
        ];

        ExecStart = "${pkgs.writeShellScript "auto-theme-check" (builtins.readFile ./auto-theme-check.sh)}";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS STARTS HERE

    # Apply mkDefault for baseline so it layers nicely under Stylix
    gtk = {enable = true;} // (applyGtkDefault lightGtkConfigRaw);
    dconf.settings = applyDconfDefault lightDconfRaw;

    stylix = {
      enable = true;
      inherit (commonHostVars) fonts; # There is no stylix.fonts.enable so this is fine!

      # Stylix's Home Manager module injects an internal package overlay itself.
      # When `home-manager.useGlobalPkgs = true` is enabled, Home Manager emits an evaluation warning because it ignores per-user nixpkgs settings.
      # This is a Stylix bug documented in https://github.com/nix-community/stylix/issues/1832 with PR https://github.com/nix-community/stylix/pull/2473.
      # For now, the recommended fix from here https://github.com/nix-community/stylix/issues/1832#issuecomment-3169274982 is used
      overlays.enable = false;

      icons = {
        enable = true; # Without this the icons were borked and I was like why is this happened then realised and was like ahhh lol
        package = lib.mkForce commonHostVars.icons.package;

        dark = lib.mkForce commonHostVars.icons.dark;
        light = lib.mkForce commonHostVars.icons.light;
      };

      cursor = {
        inherit (commonHostVars.cursor) package size;
        name = lib.mkDefault commonHostVars.cursor.light.name;
      };

      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.light}.yaml";

      # Setting gtk/gnome/qt targets broke stuff so do NOT do that!
    };
  };

  system.nixos.tags = lib.mkDefault ["light"];
  environment.etc."specialisation".text = lib.mkDefault "light";

  environment.sessionVariables = {
    GTK_THEME = lib.mkDefault commonHostVars.theme.gtk.lightName;

    # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS ENDS HERE

    # Forces applications to bypass the portal lookup, instead reading raw gsettings.
    ADW_DISABLE_PORTAL = 1; # Without this Anytype would not work...
    # I removed this because it was probably causing some issues and I don't think it's needed anymore. Double check though.
    # 12/08/2026@18:18 - 1. Oooh we got an eclipse going on right now :D. 2 - More boring but yeah confirmed that this is not needed anymore! Maybe was even causing more issues than what it solved. I dunno!

    # Some below used in scripts
    FONT_SANS_SERIF = commonHostVars.fonts.sansSerif.name;
    FONT_SERIF = commonHostVars.fonts.serif.name;
    FONT_MONOSPACE = commonHostVars.fonts.monospace.name;
    FONT_EMOJI = commonHostVars.fonts.emoji.name;
    FONT_SIZE_APPLICATIONS = commonHostVars.fonts.sizes.applications;
    FONT_SIZE_DESKTOP = commonHostVars.fonts.sizes.desktop;
    FONT_SIZE_POPUPS = commonHostVars.fonts.sizes.popups;
    FONT_SIZE_TERMINAL = commonHostVars.fonts.sizes.terminal;
  };

  /*
  The specialisations (and also the above outside specialisation light theme configuration) change the following important things:
  * system.nixos.tags
  * /etc/specialisation file
  * GTK_THEME environment variable
  * Home-manager GTK configuration
  * Home-manager dconf configuration
  * Home-manager Stylix base16 scheme and cursor name
  */

  # Specialisations generate nested configurations under /run/current-system/specialisation
  specialisation = {
    light.configuration = {pkgs, ...}: {
      home-manager.users.${userVars.username} = {
        gtk = applyGtkForce lightGtkConfigRaw;
        dconf.settings = applyDconfForce lightDconfRaw;

        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.light}.yaml";
          cursor.name = commonHostVars.cursor.light.name;
        };
      };

      system.nixos.tags = lib.mkForce ["light"];
      environment.etc."specialisation".text = lib.mkForce "light";

      environment.sessionVariables = {
        GTK_THEME = lib.mkForce commonHostVars.theme.gtk.lightName;
      };
    };

    dark.configuration = {pkgs, ...}: {
      home-manager.users.${userVars.username} = {
        gtk = applyGtkForce darkGtkConfigRaw;
        dconf.settings = applyDconfForce darkDconfRaw;

        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.dark}.yaml";
          cursor.name = commonHostVars.cursor.dark.name;
        };
      };

      system.nixos.tags = lib.mkForce ["dark"];
      environment.etc."specialisation".text = lib.mkForce "dark";

      environment.sessionVariables = {
        GTK_THEME = lib.mkForce commonHostVars.theme.gtk.darkName;
      };
    };
  };

  # Grant NOPASSWD access for the user to trigger the compiled specialisation switchers
  security.sudo.extraRules = [
    {
      users = [userVars.username];
      commands = lib.concatMap (
        sys:
          map (mode: {
            command = "/run/${sys}/specialisation/${mode}/bin/switch-to-configuration";
            options = ["NOPASSWD"];
          }) ["dark" "light"]
      ) ["booted-system" "current-system"];
    }
  ];

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
  ];
}
