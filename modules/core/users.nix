{ usersVars, ... }:

let
  # Helper function to create user configuration from userVars
  mkUserConfig = username: userVars: {
    isNormalUser = true;
    ignoreShellProgramCheck = true; # Silence shell warning since its configured in home manager
    hashedPasswordFile = "/home/${username}/.config/hashedPasswordFile";
    extraGroups = (userVars.extraGroups or [ ]) ++ [
      "audio"
      "networkmanager"
      "video"
      "wheel"
    ];
  };
in
{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true; # Normal sudo still asks for password
  };

  users = {
    mutableUsers = false; # Don't allow commands to change user configurations
    users = builtins.mapAttrs (username: userVars: mkUserConfig username userVars) usersVars;
  };

  nix.settings.allowed-users = builtins.attrNames usersVars; # Users allowed to connect to the Nix daemon
}
