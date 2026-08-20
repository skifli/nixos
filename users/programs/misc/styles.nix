{
  commonHostVars,
  config,
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
  /*
  FOR THE BELOW REASON, IN THE RAW GTK CONFIGS, gtk4.theme IS SET TO NULL
    trace: evaluation warning: The default value of gtk.gtk4.theme has changed from config.gtk.theme to null.
    You are currently using the legacy default (config.gtk.theme) because home.stateVersion is less than "26.05".
    To silence this warning and keep legacy behavior, set:
    gtk.gtk4.theme = config.gtk.theme;
    To adopt the new default behavior, set:
    gtk.gtk4.theme = null;
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
    gtk4.theme = lib.mkDefault null;
  };

  applyGtkForce = cfg: {
    iconTheme.name = lib.mkForce cfg.iconTheme.name;
    theme = {
      name = lib.mkForce cfg.theme.name;
      package = lib.mkForce cfg.theme.package;
    };
    gtk3.extraConfig = lib.mapAttrs (_: lib.mkForce) cfg.gtk3.extraConfig;
    gtk4.extraConfig = lib.mapAttrs (_: lib.mkForce) cfg.gtk4.extraConfig;
    gtk4.theme = lib.mkForce null;
  };

  applyDconfDefault = lib.mapAttrsRecursive (_: lib.mkDefault);
  applyDconfForce = lib.mapAttrsRecursive (_: lib.mkForce);

  kdeglobalsBase = ''
    TerminalApplication=${userVars.programs.terminal}
    TerminalService=${
      if userVars.programs.terminal == "ghostty"
      then "com.mitchellh.ghostty"
      else userVars.programs.terminal
    }.desktop

    [KFileDialog Settings]
    Allow Expansion=true
    Automatically select filename extension=true
    Breadcrumb Navigation=true
    Decoration position=2
    Show Full Path=true
    Show Inline Previews=true
    Show Preview=true
    Show Speedbar=true
    Show hidden files=true
    Sort by=Name
    Sort directories first=true
    Sort hidden files last=false
    Sort reversed=false
    Speedbar Width=156
    View Style=DetailTree

    [PreviewSettings]
    EnableRemoteFolderThumbnail=true
    MaximumRemoteSize=104857600
  '';

  qtThemeStyleCapitalised = lib.toSentenceCase commonHostVars.theme.qt.style;
in {
  environment.systemPackages = with pkgs; [
    # For debugging
    glib

    kdePackages.${commonHostVars.theme.qt.style}
  ];

  # Enable Qt styling and set the platform theme platform
  qt =
    {
      enable = true;
    }
    // commonHostVars.theme.qt;

  home-manager.users.${userVars.username} = {lib, ...}: {
    # Force auto-theme-check to restart after every HM activation/rebuild because it didn't before and since we always rebuild into light if we don't do this this can cause some theme mismatches.
    home.activation.triggerThemeCheck = lib.hm.dag.entryAfter ["reloadSystemd"] ''
      run ${pkgs.systemd}/bin/systemctl --user restart auto-theme-check.service
    '';

    systemd.user.services.auto-theme-check = {
      Unit = {
        Description = "Solar position watcher and theme switcher daemon";
        X-SwitchMethod = "keep-old"; # Preven sd-switch in HM from restaring this service
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

    # I don't think this is needed anymore but just in case...
    xdg.dataFile."color-schemes/${qtThemeStyleCapitalised}Dark.colors".source = "${pkgs.kdePackages.${commonHostVars.theme.qt.style}}/share/color-schemes/${qtThemeStyleCapitalised}Dark.colors";
    xdg.dataFile."color-schemes/${qtThemeStyleCapitalised}Light.colors".source = "${pkgs.kdePackages.${commonHostVars.theme.qt.style}}/share/color-schemes/${qtThemeStyleCapitalised}Light.colors";

    # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS STARTS HERE

    gtk =
      {
        enable = true;

        # THIS SECTION IS NOT PART OF DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS
        # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS PAUSE
        font = {
          name = commonHostVars.fonts.sansSerif.name;
          size = commonHostVars.fonts.sizes.applications;
          package = commonHostVars.fonts.sansSerif.package;
        }; # Have to manually do this and the below config because the Stylix gtk/gnome/qt targets are disabled so as not to break automatic theme switching, etc.
      }
      # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS RESUME
      // (applyGtkDefault lightGtkConfigRaw);
    dconf.settings = lib.mkMerge [
      (applyDconfDefault lightDconfRaw)
      # THIS SECTION IS NOT PART OF DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS
      # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS PAUSE
      {
        "org/gnome/desktop/interface" = {
          font-name = "${commonHostVars.fonts.sansSerif.name} ${toString commonHostVars.fonts.sizes.applications}";
          document-font-name = "${commonHostVars.fonts.sansSerif.name} ${toString commonHostVars.fonts.sizes.applications}";
          monospace-font-name = "${commonHostVars.fonts.monospace.name} ${toString commonHostVars.fonts.sizes.terminal}";

          cursor-size = commonHostVars.cursor.size;
          cursor-theme = config.home-manager.users.${userVars.username}.stylix.cursor.name; # Dynamically follow based on dark / light specialisation without having to rewrite this itself!
        };
      }
      # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS RESUME
    ];

    xdg.configFile."kdeglobals".text = lib.mkDefault ''
      ${builtins.readFile "${pkgs.kdePackages.${commonHostVars.theme.qt.style}}/share/color-schemes/${qtThemeStyleCapitalised}Light.colors"}
      ${kdeglobalsBase}
    '';

    stylix = {
      # THIS SECTION IS NOT PART OF DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS
      # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS PAUSE
      autoEnable = false;
      targets = lib.genAttrs (userVars.stylixTargetsWhitelist
        ++ [
          "fontconfig"
          "font-packages"
        ]) (_name: {
        enable = true;
      });

      # DAY THEME CONFIGURATION OUTSIDE THE SPECIALISATIONS RESUME
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
    light.configuration = {
      lib,
      pkgs,
      ...
    }: {
      home-manager.users.${userVars.username} = {lib, ...}: {
        # Disable restart trigger when switching into this specialisation
        home.activation.triggerThemeCheck = lib.mkForce (lib.hm.dag.entryAfter ["reloadSystemd"] ":");

        gtk = applyGtkForce lightGtkConfigRaw;
        dconf.settings = applyDconfForce lightDconfRaw;

        xdg.configFile."kdeglobals".text = lib.mkForce ''
          ${builtins.readFile "${pkgs.kdePackages.${commonHostVars.theme.qt.style}}/share/color-schemes/${qtThemeStyleCapitalised}Light.colors"}
          ${kdeglobalsBase}
        '';

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

    dark.configuration = {
      lib,
      pkgs,
      ...
    }: {
      home-manager.users.${userVars.username} = {lib, ...}: {
        # Disable restart trigger when switching into this specialisation
        home.activation.triggerThemeCheck = lib.mkForce (lib.hm.dag.entryAfter ["reloadSystemd"] ":");

        gtk = applyGtkForce darkGtkConfigRaw;
        dconf.settings = applyDconfForce darkDconfRaw;

        xdg.configFile."kdeglobals".text = lib.mkForce ''
          ${builtins.readFile "${pkgs.kdePackages.${commonHostVars.theme.qt.style}}/share/color-schemes/${qtThemeStyleCapitalised}Dark.colors"}
          ${kdeglobalsBase}
        '';

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
