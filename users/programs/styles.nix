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
  switch-system-specialisation = spec: ''
    activate_script="/run/current-system/specialisation/${spec}/bin/switch-to-configuration"

    if [ -x "$activate_script" ]; then
      "$activate_script" switch
    else
      echo "Missing system specialisation switch script: $activate_script" >&2
      exit 1
    fi
  '';

  call-screen-transition = ''
    NIRI_SOCKET="''$(find "$runtime_dir" -name 'niri*.sock' 2>/dev/null | head -n 1)"
    if [ -n "$NIRI_SOCKET" ]; then
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
          # darkman config only; switching is handled by the root service below.
        };
      };
    };

  darkman-switcher = pkgs.writeShellScript "darkman-theme-switcher" ''
    set -euo pipefail

    user_uid="$(${pkgs.coreutils}/bin/id -u ${userVars.username})"
    runtime_dir="/run/user/$user_uid"
    bus_addr="unix:path=$runtime_dir/bus"
    current_mode="$(XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="$bus_addr" ${pkgs.darkman}/bin/darkman get 2>/dev/null || echo light)"
    echo "Initial mode: $current_mode"

    while true; do
      if [ ! -S "$runtime_dir/bus" ]; then
        sleep 2
        continue
      fi

      new_mode="$(XDG_RUNTIME_DIR="$runtime_dir" DBUS_SESSION_BUS_ADDRESS="$bus_addr" ${pkgs.darkman}/bin/darkman get 2>/dev/null || echo light)"

      if [ "$new_mode" != "$current_mode" ]; then
        echo "Switching from $current_mode to $new_mode"

        if [ "$new_mode" = "dark" ]; then
          ${switch-system-specialisation "night"}
        else
          ${switch-system-specialisation "day"}
        fi

        current_mode="$new_mode"
        echo "$new_mode" > /run/darkman-mode.current
        echo "Triggering screen transition..."
        ${call-screen-transition}
      fi

      sleep 2
    done
  '';
in
{
  systemd.services.darkman-theme-switcher = {
    description = "Monitor darkman mode changes and switch system specialisations";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${darkman-switcher}";
      Restart = "always";
      RestartSec = 5;
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