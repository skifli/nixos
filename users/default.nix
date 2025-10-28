{
  inputs,
  usersVars,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true; # Use the same nixpkgs instance and its settings as the main system config
    useUserPackages = true; # Make packages not available system-wide, instead in ~/.nix-profile
    # extraSpecialArgs = { inherit commonHostVars hostVars; }; # Home manager WHY do you use this ;-;

    users = builtins.mapAttrs (username: userVars: {
      programs.home-manager.enable = true; # Let Home Manager install and manage itself.

      xdg = {
        enable = true; # Ensures ENV variables are set up so apps follow the XDG Base Dir Spec

        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };

      home = {
        sessionVariables.EDITOR = userVars.programs.editor;
        sessionVariables.BROWSER = userVars.programs.browser;
        sessionVariables.TERMINAL = userVars.programs.terminal;

        username = username;
        homeDirectory = "/home/${username}";

        file.".config/hashedPasswordFile".source = ./${username}/secrets/hashedPasswordFile;
        file.".local/share/wallpaper.jpg".source = ./${username}/secrets/${userVars.wallpaper}.jpg;

        stateVersion = "23.11"; # DO NOT CHANGE!
      };
    }) usersVars; # For each user
  };
}
