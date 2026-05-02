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
  switch-hm-specialisation = spec: ''
    hm_gens=$(${
      if config.nix.package != null then config.nix.package else pkgs.nixVersions.latest
    }/bin/nix-store -q --referrers ~/.local/state/nix/profiles/home-manager)
    "$(${pkgs.toybox}/bin/find $hm_gens -maxdepth 1 -type d -name specialisation)/${spec}/activate"
  '';

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
          # We now handle theme switching via home.activation hook below
        };
      };
    };
in
{
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
                if [ "$new_mode" = "dark" ]; then
                  echo "Activating night specialisation..."
                  ${switch-hm-specialisation "night"}
                  if [ $? -eq 0 ]; then
                    echo "Night specialisation activated"
                  else
                    echo "Night specialisation failed"
                  fi
                else
                  echo "Activating day specialisation..."
                  ${switch-hm-specialisation "day"}
                  if [ $? -eq 0 ]; then
                    echo "Day specialisation activated"
                  else
                    echo "Day specialisation failed"
                  fi
                fi
                echo "Triggering screen transition..."
                ${call-screen-transition}
                echo "$new_mode" > /tmp/darkman-mode.current
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
        # xdg.dataFile."home-manager/specialisation".text = name;
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
        # xdg.dataFile."home-manager/specialisation".text = name;
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