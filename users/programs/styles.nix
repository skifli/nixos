{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  userVars,
  inputs,
  ...
}: let
  # Centralized light configuration reading from host vars
  lightGtkConfigRaw = {
    iconTheme.name = commonHostVars.icons.light;
    theme = {
      name = commonHostVars.theme.gtk.dayName;
      package = commonHostVars.theme.gtk.package;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
      gtk-theme-name = commonHostVars.theme.gtk.dayName;
    };
  };

  lightDconfRaw = {
    "org/gnome/desktop/interface" = {
      color-scheme = "default";
      gtk-theme = commonHostVars.theme.gtk.dayName;
    };
    "org/gnome/desktop/a11y/interface" = {
      high-contrast = false;
    };
  };

  # Centralized dark configuration reading from host vars
  darkGtkConfigRaw = {
    iconTheme.name = commonHostVars.icons.dark;
    theme = {
      name = commonHostVars.theme.gtk.nightName;
      package = commonHostVars.theme.gtk.package;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = commonHostVars.theme.gtk.nightName;
    };
  };

  darkDconfRaw = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = commonHostVars.theme.gtk.nightName;
    };
    "org/gnome/desktop/a11y/interface" = {
      # For some godforsaken reason this is the only thing that makes Anytype activate its dark mode. NOTHING else that I've set here does! Arggghhh!! At least it works now, but I swear this is going to cause some adverse affects later that will take me forever to trace back to this damned variable ;-;.
      high-contrast = true;
    };
  };

  applyDefault = cfg: {
    iconTheme.name = lib.mkDefault cfg.iconTheme.name;
    theme = {
      name = lib.mkDefault cfg.theme.name;
      package = lib.mkDefault cfg.theme.package;
    };
    gtk3.extraConfig = lib.mapAttrs (_: lib.mkDefault) cfg.gtk3.extraConfig;
    gtk4.extraConfig = lib.mapAttrs (_: lib.mkDefault) cfg.gtk4.extraConfig;
  };

  applyForce = cfg: {
    iconTheme.name = lib.mkForce cfg.iconTheme.name;
    theme = {
      name = lib.mkForce cfg.theme.name;
      package = lib.mkForce cfg.theme.package;
    };
    gtk3.extraConfig = lib.mapAttrs (_: lib.mkForce) cfg.gtk3.extraConfig;
    gtk4.extraConfig = lib.mapAttrs (_: lib.mkForce) cfg.gtk4.extraConfig;
  };
in {
  environment.sessionVariables = {
    # Forces applications to bypass the portal lookup, instead reading raw gsettings.
    ADW_DISABLE_PORTAL = "1"; # Without this Anytype would not work...

    GTK_THEME = lib.mkDefault commonHostVars.theme.gtk.dayName;
  };

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
    stylix = {
      enable = true;
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";

      cursor = {
        inherit (commonHostVars.cursor) package size;
        name = lib.mkDefault commonHostVars.cursor.day.name;
      };
      inherit (commonHostVars) icons fonts;

      # Setting gtk/gnome/qt targets broke stuff so do NOT do that!
    };

    # Apply mkDefault for baseline so it layers nicely under Stylix
    gtk = {enable = true;} // (applyDefault lightGtkConfigRaw);

    dconf.settings = lib.mapAttrsRecursive (_: lib.mkDefault) lightDconfRaw;

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
              ${sunwaitBin} poll ${latVal}${latDir} ${lonVal}${lonDir} >/dev/null 2>&1
              STATUS=$?
              set -e

              # 2: It is DAY or twilight. 3: It is NIGHT. 1: It is an Error.
              if [ $STATUS -eq 2 ]; then
                WANTED="day"
              elif [ $STATUS -eq 3 ]; then
                WANTED="night"
              else
                echo "Sunwait error code: $STATUS" >&2
                sleep 60
                continue
              fi

              # 2. Query system specialisation file
              CURRENT_TAG=$(cat /etc/specialisation 2>/dev/null || echo "")

              # 3. Trigger switch if states mismatch
              if [ "$WANTED" != "$CURRENT_TAG" ]; then
                notify-send -e -a "nixos" -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Auto-theme switcher" "Triggering theme switch" || true
                ${switcherBin}
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
              fi
            done
          '';
        in "${autoCheckScript}";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };

  /*
  The specialisations change the following important things:
  * GTK_THEME environment variable
  * Home-manager Stylix base16 scheme and cursor name
  * Home-manager GTK configuration
  * Home-manager dconf configuration
  */

  # Specialisations generate nested configurations under /run/current-system/specialisation
  specialisation = {
    day.configuration = {pkgs, ...}: {
      system.nixos.tags = ["day"];
      environment.etc."specialisation".text = "day";

      environment.sessionVariables = {
        GTK_THEME = lib.mkForce commonHostVars.theme.gtk.dayName;
      };

      home-manager.users.${userVars.username} = {
        # Explicitly apply mkForce
        gtk = applyForce lightGtkConfigRaw;

        dconf.settings = lib.mapAttrsRecursive (_: lib.mkForce) lightDconfRaw;

        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";
          cursor.name = commonHostVars.cursor.day.name;
        };
      };
    };

    night.configuration = {pkgs, ...}: {
      system.nixos.tags = ["night"];
      environment.etc."specialisation".text = "night";

      environment.sessionVariables = {
        GTK_THEME = lib.mkForce commonHostVars.theme.gtk.nightName;
      };

      home-manager.users.${userVars.username} = {
        # Explicitly apply mkForce
        gtk = applyForce darkGtkConfigRaw;

        dconf.settings = lib.mapAttrsRecursive (_: lib.mkForce) darkDconfRaw;

        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.night}.yaml";
          cursor.name = commonHostVars.cursor.night.name;
        };
      };
    };
  };

  # Preserve session variables across sudo
  security.sudo.extraConfig = ''
    Defaults env_keep += "XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS WAYLAND_DISPLAY"
  '';

  # Grant NOPASSWD access for the user to trigger the compiled specialisation switchers
  security.sudo.extraRules = [
    {
      users = [userVars.username];
      commands = [
        {
          command = "/run/booted-system/specialisation/night/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/booted-system/specialisation/day/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/specialisation/night/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/specialisation/day/bin/switch-to-configuration";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
  ];
}
