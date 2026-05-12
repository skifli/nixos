{
  config,
  lib,
  usersVars,
  ...
}:

let
  # Helper function to create user configuration from userVars
  mkUserConfig = username: userVars:
    let
      ageName = "${username}-hashedPasswordFile";
      passwordSource =
        if builtins.hasAttr ageName config.age.secrets then
          config.age.secrets.${ageName}.path
        else
          null;

      passwordAttrs = lib.optionalAttrs (passwordSource != null) {
        hashedPasswordFile = passwordSource;
      };
    in
    {
      isNormalUser = true;
      ignoreShellProgramCheck = true; # Silence shell warning since its configured in home manager

      # Prefer agenix-managed secrets for user passwords.
      # If no secret is present, omit hashedPasswordFile so rebuilds do not hard-fail.
      # With users.mutableUsers = true, existing passwords remain unchanged.
      # Provide a secret for first bootstrap.
      extraGroups = (userVars.extraGroups or [ ]) ++ [
        "audio"
        "networkmanager"
        "video"
        "wheel"
      ];
    } // passwordAttrs;
in
{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true; # Normal sudo still asks for password
  };

  users = {
    mutableUsers = true; # Allow commands to change user configurations
    users = (builtins.mapAttrs (username: userVars: mkUserConfig username userVars) usersVars) // {
      rescue = {
        isNormalUser = true;
        password = "rescue";
      };
    };
  };

  nix.settings.allowed-users = builtins.attrNames usersVars; # Users allowed to connect to the Nix daemon
}
