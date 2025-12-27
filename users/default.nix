{
  commonHostVars,
  inputs,
  pkgs,
  usersVars,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # https://mynixos.com/home-manager/option/xdg.portal.enable
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  home-manager = {
    backupFileExtension = "hm-backup";
    # overwriteBackup = true;

    useGlobalPkgs = true; # Use the same nixpkgs instance and its settings as the main system config
    useUserPackages = true; # Make packages not available system-wide, instead in ~/.nix-profile
    # extraSpecialArgs = { inherit commonHostVars hostVars; }; # Home manager WHY do you use this ;-;

    users = builtins.mapAttrs (username: userVars: {
      programs.home-manager.enable = true; # Let Home Manager install and manage itself.

      xdg = {
        configFile."mimeapps.list".force = true;

        enable = true; # Ensures ENV variables are set up so apps follow the XDG Base Dir Spec

        portal = {
          enable = true;

          # https://mynixos.com/home-manager/option/xdg.portal.xdgOpenUsePortal
          xdgOpenUsePortal = false;

          config.common = {
            default = [
              "luminous"
              "kde"
            ];
          };

          extraPortals = with pkgs; [
            xdg-desktop-portal-luminous
            kdePackages.xdg-desktop-portal-kde
            # xdg-desktop-portal-luminous
          ];
        };

        mimeApps.enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };

      home = {
        sessionPath = [
          "/home/${userVars.username}/.cargo/bin"
        ];

        sessionVariables = {
          BROWSER = userVars.programs.browser;
          EDITOR = userVars.programs.editor;
          SHELL = userVars.programs.shell;
          TERM = userVars.programs.terminal;
          VISUAL = userVars.programs.visual;
        };

        shellAliases = {
          sup = "sudo -E"; # sudo --preserve-env
        }
        // commonHostVars.shellAliases;

        username = username;
        homeDirectory = "/home/${username}";

        file.".config/hashedPasswordFile".source = ./${username}/secrets/hashedPasswordFile;
        file.".local/share/wallpaper.jpg".source = ./${username}/secrets/${userVars.wallpaper}.jpg;

        file = {
          ".local/bin" = {
            source = ./${userVars.username}/scripts;
            recursive = true;
          };
        };

        stateVersion = "25.05"; # DO NOT CHANGE!
      };
    }) usersVars; # For each user
  };

  xdg = {
    # enable = true; # Ensures ENV variables are set up so apps follow the XDG Base Dir Spec
    terminal-exec.enable = true; # https://discourse.nixos.org/t/how-to-set-default-terminal-for-desktop-entries/69190/4

    portal = {
      enable = true; # ABSOLUTE DINGLEBERRY

      # https://mynixos.com/nixpkgs/option/xdg.portal.xdgOpenUsePortal
      xdgOpenUsePortal = false;

      config.common = {
        default = [
          "luminous"
          "kde"
        ];
      };

      extraPortals = with pkgs; [
        xdg-desktop-portal-luminous
        kdePackages.xdg-desktop-portal-kde
      ];
    };

    mime.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xdg-utils

    xdg-desktop-portal
    xdg-desktop-portal-luminous
    kdePackages.xdg-desktop-portal-kde
  ];
}
