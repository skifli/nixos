{
  commonHostVars,
  lib,
  inputs,
  pkgs,
  userVars,
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
  };

  specialisation = {
    day.configuration = {pkgs, ...}: let
      name = "day";
    in {
      system.nixos.tags = [name];
      environment.etc."specialisation".text = name;

      home-manager.users.${userVars.username} = {
        gtk.iconTheme.name = commonHostVars.icons.light;

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

        stylix = {
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${commonHostVars.theme.night}.yaml";
          cursor.name = commonHostVars.cursor.night.name;
        };
      };
    };
  };

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
