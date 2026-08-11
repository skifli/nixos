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

  lightDconfInterfaceRaw = {
    color-scheme = "default";
    gtk-theme = commonHostVars.theme.gtk.dayName;
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

  darkDconfInterfaceRaw = {
    color-scheme = "prefer-dark";
    gtk-theme = commonHostVars.theme.gtk.nightName;
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

    dconf.settings = {
      "org/gnome/desktop/interface" = lib.mapAttrs (_: lib.mkDefault) lightDconfInterfaceRaw;
    };

    systemd.user.services.auto-theme-check = {
      Unit = {
        Description = "Check solar position and switch NixOS theme specialisation";
      };
      Service = {
        Type = "oneshot";

        # Injects the desktop schemas and links sys binaries for notifications
        Environment = [
          "XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
          "PATH=${lib.makeBinPath [ pkgs.libnotify pkgs.coreutils pkgs.bash pkgs.niri pkgs.sudo ]}"
          "USER=${userVars.username}" 
          
          "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"
          "WAYLAND_DISPLAY=wayland-0"
          "XDG_RUNTIME_DIR=/run/user/%U"
        ];

        ExecStart = let
          lat = toString hostVars.latitude;
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

            # 1. Poll sunwait for solar position
            set +e
            ${sunwaitBin} poll ${lat}N ${lonVal}${lonDir} >/dev/null 2>&1
            STATUS=$?
            set -e

            # 2: It is DAY or twilight. 3: It is NIGHT. 1: It is an Error.
            if [ $STATUS -eq 2 ]; then
              WANTED="day"
            elif [ $STATUS -eq 3 ]; then
              WANTED="night"
            else
              echo "Sunwait error code: $STATUS" >&2
              exit 1
            fi

            # 2. Query desktop state instead of using a state file
            # Returns 'prefer-light', 'prefer-dark', or 'default'
            CURRENT_SCHEME=$(${pkgs.glib}/bin/gsettings get org.gnome.desktop.interface color-scheme)

            if [ "$WANTED" = "day" ]; then
              # If we want day but the system is currently dark, we need to switch
              if [ "$CURRENT_SCHEME" = "'prefer-dark'" ]; then
                NEED_SWITCH=true
              else
                NEED_SWITCH=false
              fi
            else
              # If we want night but the system is currently light/default, we need to switch
              if [ "$CURRENT_SCHEME" != "'prefer-dark'" ]; then
                NEED_SWITCH=true
              else
                NEED_SWITCH=false
              fi
            fi

            # 3. Trigger switch if states mismatch
            if [ "$NEED_SWITCH" = true ]; then
              notify-send -e -a "nixos" -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Auto-theme switcher" "Triggering theme switch"
              ${switcherBin}
            fi
          '';
        in "${autoCheckScript}";
      };
    };

    systemd.user.timers.auto-theme-check = {
      Unit = {
        Description = "Automagic solar time checker";
      };
      Timer = {
        OnCalendar = "*:0/10"; # Runs every 10 minutes to verify solar state
        Persistent = true;
      };
      Install = {
        WantedBy = ["timers.target"];
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

        dconf.settings = {
          "org/gnome/desktop/interface" = lib.mapAttrs (_: lib.mkForce) lightDconfInterfaceRaw;
        };
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

        dconf.settings = {
          "org/gnome/desktop/interface" = lib.mapAttrs (_: lib.mkForce) darkDconfInterfaceRaw;
        };
        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.night}.yaml";
          cursor.name = commonHostVars.cursor.night.name;
        };
      };
    };
  };

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
