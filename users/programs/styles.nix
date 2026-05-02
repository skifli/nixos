# Partially based on code from https://github.com/Weathercold/nixfiles/blob/master/home/modules/services/scheduling/darkman.nix

{
  commonHostVars,
  config,
  hostVars,
  lib,
  inputs,
  pkgs,
  userVars,
  ...
}:

let
  call-screen-transition = ''
    export NIRI_SOCKET="''$(find /run/user/$(id -u) -name 'niri*.sock' 2>/dev/null | head -n 1)"
    if [[ -n "$NIRI_SOCKET" ]]; then
      echo "Using socket found at $NIRI_SOCKET"
      ${lib.getExe config.programs.niri.package} msg action do-screen-transition
    else
      echo "Cannot find NIRI_SOCKET; skipping screen transition"
    fi
  '';

  enableDarkmanModule =
    { ... }:

    {
      services.darkman = {
        enable = true;

        settings = {
          lat = hostVars.latitude;
          lng = hostVars.longitude;
          usegeoclue = false;

          dbusserver = true;
          portal = true;
          # Note: old darkModeScripts/lightModeScripts removed - newer darkman doesn't support them
          # Theme switching is handled by the user service below.
        };
      };
    };

  apply-specialisation = pkgs.writeShellScript "darkman-apply-specialisation" ''
    set -euo pipefail

    mode="$(${pkgs.coreutils}/bin/cat /tmp/darkman-mode.request 2>/dev/null || true)"
    case "$mode" in
      dark|night)
        spec="night"
        ;;
      light|day)
        spec="day"
        ;;
      *)
        echo "darkman-apply-specialisation: unknown mode '$mode'" >&2
        exit 0
        ;;
    esac

    activate="/run/current-system/specialisation/$spec/bin/switch-to-configuration"
    if [ ! -x "$activate" ]; then
      echo "darkman-apply-specialisation: missing $activate" >&2
      exit 1
    fi

    exec "$activate" switch
  '';
in
{
  systemd.services.darkman-apply-specialisation = {
    description = "Apply darkman system specialisation";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${apply-specialisation}";
    };
  };

  systemd.paths.darkman-apply-specialisation = {
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = [ "/tmp/darkman-mode.request" ];
      Unit = "darkman-apply-specialisation.service";
    };
  };

  home-manager.users.${userVars.username} = {
    stylix = {
      enable = true;
      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";

      cursor = {
        package = commonHostVars.cursor.package;
        size = commonHostVars.cursor.size;
        name = lib.mkDefault commonHostVars.cursor.day.name;
      };
      icons = commonHostVars.icons;
      fonts = commonHostVars.fonts;

      # targets."${userVars.programs.browser}-browser".enable = false;
    };

    gtk = {
      enable = true;

      iconTheme = {
        package = commonHostVars.icons.package;
        name = lib.mkDefault commonHostVars.icons.light;
      };
    };

    systemd.user.services.darkman-theme-switcher = {
      Unit = {
        Description = "Monitor darkman mode changes and switch specialisations";
        After = [ "graphical-session.target" "darkman.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = let
          script = pkgs.writeShellScript "darkman-theme-switcher" ''
            set -x
            while true; do
              current_mode=$(cat /tmp/darkman-mode.current 2>/dev/null || echo light)
              new_mode=$(${pkgs.darkman}/bin/darkman get 2>/dev/null || echo light)
              if [ "$new_mode" != "$current_mode" ]; then
                echo "Switching from $current_mode to $new_mode"
                printf '%s\n' "$new_mode" > /tmp/darkman-mode.request
                echo "$new_mode" > /tmp/darkman-mode.current
                echo "Triggering screen transition..."
                ${call-screen-transition}
              fi
              sleep 2
            done
          '';
        in "${script}";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  specialisation = {
    day.configuration =
      {
        pkgs,
        ...
      }:
      let
        name = "day";
      in
      {
        system.nixos.tags = [ name ];
        environment.etc."specialisation".text = name;

        home-manager.users.${userVars.username} = {
          gtk.iconTheme.name = commonHostVars.icons.light;

          stylix = {
            base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.day}.yaml";
            cursor.name = commonHostVars.cursor.day.name;
          };
        };
      };

    night.configuration =
      {
        pkgs,
        ...
      }:
      let
        name = "night";
      in
      {
        system.nixos.tags = [ name ];
        environment.etc."specialisation".text = name;

        home-manager.users.${userVars.username} = {
          gtk.iconTheme.name = commonHostVars.icons.dark;

          stylix = {
            base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.night}.yaml";
            cursor.name = commonHostVars.cursor.night.name;
          };
        };
      };
  };

  home-manager.sharedModules = [
    enableDarkmanModule
    inputs.stylix.homeModules.stylix
  ];
}