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

  home-manager.users.${userVars.username} = {
    systemd.user.services.auto-theme-check = {
      Unit = {
        Description = "Solar position watcher and theme switcher daemon";
        # Ensure it restarts automatically if interrupted or resumed from sleep
      };
      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5s";

        Environment = [
          "PATH=/run/wrappers/bin:${lib.makeBinPath [pkgs.libnotify pkgs.coreutils pkgs.bash pkgs.niri]}"
          "USER=${userVars.username}"
        ];

        ExecStart = let
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
          sunwaitBin = "${pkgs.sunwait}/bin/sunwait";
          switcherBin = "/home/${userVars.username}/.local/bin/theme-switcher.sh";

          autoCheckScript = pkgs.writeShellScript "auto-theme-check" ''
            set -euo pipefail

            # Dynamically resolve paths for notifications and desktop commands (like niri workspace transitions)
            RUN_UID=$(id -u)
            export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$RUN_UID/bus"
            export XDG_RUNTIME_DIR="/run/user/$RUN_UID"
            export WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-wayland-1}"

            while true; do
              # 1. Poll sunwait for solar position
              set +e
              ${sunwaitBin} poll ${latVal}${latDir} ${lonVal}${lonDir} >/tmp/sunwait.log 2>&1 # Redirects stdout to a log file not dev/null
              STATUS=$?
              set -e

              # 2: It is DAY or twilight. 3: It is NIGHT. 1: It is an Error.
              if [ $STATUS -eq 2 ]; then
                WANTED="light"
              elif [ $STATUS -eq 3 ]; then
                WANTED="dark"
              else
                echo "Sunwait error code: $STATUS" >&2
                sleep 60
                continue
              fi

              # 2. Query system specialisation file
              CURRENT_TAG=$(cat /etc/specialisation 2>/dev/null || echo "light")

              # 3. Trigger switch if states mismatch
              if [ "$WANTED" != "$CURRENT_TAG" ]; then
                echo "Theme mismatch detected. Switching to $WANTED mode."
                notify-send -e -a "nixos" -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Auto-theme switcher" "Switching to $WANTED mode..."
                ${switcherBin} "$WANTED"
              fi

              # 4. Wait until the next solar transition (sunrise or sunset)
              # Default behavior of 'sunwait wait' without 'rise'/'set' option is 'both',
              # So, it blocks until the very next sunrise or sunset event occurs.
              echo "Waiting until next sunrise or sunset..."
              set +e
              ${sunwaitBin} wait ${latVal}${latDir} ${lonVal}${lonDir}
              WAIT_STATUS=$?
              set -e

              if [ $WAIT_STATUS -ne 0 ]; then
                echo "Sunwait wait returned error code: $WAIT_STATUS. Retrying in 60s..."
                sleep 60
              else
                # Pause 5 seconds to prevent I think what is a race-condition where wait unblocked, the script looped back, poll was run, but it was too soon and poll just about hit the current state and didn't update to the next one, causing the script to break.
                sleep 5
              fi
            done
          '';
        in "${autoCheckScript}";
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
    FONT_SIZE_TERMINAl = commonHostVars.fonts.sizes.terminal;
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
