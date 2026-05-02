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

        settings = (
          lib.mkMerge [
            {
              lat = hostVars.latitude;
              lng = hostVars.longitude;
              usegeoclue = false;

              dbusserver = true;
              portal = true;

              lightModeScripts."00-switch-hm-specialisation" = switch-hm-specialisation "day";
              darkModeScripts."00-switch-hm-specialisation" = switch-hm-specialisation "night";
            }
            (lib.mkIf (userVars.programs.compositor == "niri") {
              lightModeScripts."01-call-screen-transition" = call-screen-transition;
              darkModeScripts."01-call-screen-transition" = call-screen-transition;
            })
          ]
        );
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

          services.vicinae.settings.theme.name = lib.mkIf (
            userVars.programs.launcher == "vicinae"
          ) "vicinae-light";

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

          services.vicinae.settings.theme.name = lib.mkIf (
            userVars.programs.launcher == "vicinae"
          ) "vicinae-dark";

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
