{
  inputs,
  pkgs,
  usersVars,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
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
        enable = true; # Ensures ENV variables are set up so apps follow the XDG Base Dir Spec

        portal = {
          xdgOpenUsePortal = true;
          config.common = {
            default = [
              "wlr"
              "gtk"
            ];
          };
          extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
          ];
        };

        mimeApps.enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };

      home = {
        sessionVariables = {
          BROWSER = userVars.programs.browser;
          EDITOR = userVars.programs.editor;
          SHELL = userVars.programs.shell;
          TERM = userVars.programs.terminal;
          VISUAL = userVars.programs.visual;
        };

        shellAliases = {
          sup = "sudo -E"; # sudo --preserve-env
        };

        username = username;
        homeDirectory = "/home/${username}";

        file.".config/hashedPasswordFile".source = ./${username}/secrets/hashedPasswordFile;
        file.".local/share/wallpaper.jpg".source = ./${username}/secrets/${userVars.wallpaper}.jpg;

        stateVersion = "25.05"; # DO NOT CHANGE!
      };
    }) usersVars; # For each user
  };

  xdg.terminal-exec.enable = true; # https://discourse.nixos.org/t/how-to-set-default-terminal-for-desktop-entries/69190/4
}
