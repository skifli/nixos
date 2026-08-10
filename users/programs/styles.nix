{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  userVars,
  inputs,
  ...
}: {
  home-manager.users.${userVars.username} = {
    stylix = {
      enable = true;
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";

      cursor = {
        inherit (commonHostVars.cursor) package size;
        name = lib.mkDefault commonHostVars.cursor.day.name;
      };
      inherit (commonHostVars) icons fonts;
    };

    gtk = {
      enable = true;

      iconTheme = {
        inherit (commonHostVars.icons) package;
        name = lib.mkDefault commonHostVars.icons.light;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-light";
      };
    };

    systemd.user.services.auto-theme-check = {
      Unit = {
        Description = "Check solar position and switch NixOS theme specialisation";
      };
      Service = {
        Type = "oneshot";
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

            set +e # Temporarily allow non-zero exit codes to prevent sunwait from tripping set -e
            ${sunwaitBin} poll ${lat}N ${lonVal}${lonDir} >/dev/null 2>&1
            STATUS=$?
            set -e # Turn strict errors back on

            # 2: It is DAY or twilight. 3: It is NIGHT. 1: It is an Error.
            if [ "$STATUS" -eq 2 ]; then
              WANTED="day"
            elif [ "$STATUS" -eq 3 ]; then
              WANTED="night"
            else
              echo "Sunwait error code: $STATUS" >&2
              exit 1
            fi

            # Using a mutable path
            STATE_FILE="/home/${userVars.username}/.local/state/current-theme"
            CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "day")

            if [ "$WANTED" != "$CURRENT" ]; then
                notify-send -e -a "nixos" -i "/home/${userVars.username}/.local/share/misc/nix-snowflake-rainbow.svg" -u low -t 5000 "Auto-theme switcher" "Switching to $WANTED mode"
                ${switcherBin} "$WANTED"
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

  # Specialisations generate nested configurations under /run/current-system/specialisation/
  specialisation = {
    day.configuration = {pkgs, ...}: let
      name = "day";
    in {
      system.nixos.tags = [name];
      environment.etc."specialisation".text = name;

      home-manager.users.${userVars.username} = {
        gtk.iconTheme.name = commonHostVars.icons.light;

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-light";
          };
        };

        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";
          cursor.name = commonHostVars.cursor.day.name;
        };
      };
    };

    night.configuration = {pkgs, ...}: let
      name = "night";
    in {
      system.nixos.tags = [name];
      environment.etc."specialisation".text = name;

      home-manager.users.${userVars.username} = {
        gtk.iconTheme.name = commonHostVars.icons.dark;

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
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
