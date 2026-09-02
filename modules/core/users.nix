{
  config,
  lib,
  usersVars,
  ...
}: let
  usernameList = builtins.attrNames usersVars;

  # Helper function to create user configuration from userVars
  mkUserConfig = username: userVars: let
    ageName = "${username}-hashedPasswordFile";
    passwordSource =
      if builtins.hasAttr ageName config.age.secrets
      then config.age.secrets.${ageName}.path
      else null;
    passwordAttrs = lib.optionalAttrs (passwordSource != null) {hashedPasswordFile = passwordSource;};

    userIndex = lib.lists.indexOf username usernameList;

    uidAttr = {uid = 1000 + userIndex;};
  in
    {
      isNormalUser = true;
      ignoreShellProgramCheck = true; # Silence shell warning since its configured in home manager

      # Prefer agenix-managed secrets for user passwords.
      # If no secret is present, omit hashedPasswordFile so rebuilds do not hard-fail.
      # With users.mutableUsers = true, existing passwords remain unchanged.
      # Provide a secret for first bootstrap.
      extraGroups =
        (userVars.extraGroups or [])
        ++ [
          "audio"
          "networkmanager"
          "video"
          "wheel"
        ];
    }
    // passwordAttrs // uidAttr;

  rescuePasswordAttrs =
    lib.optionalAttrs
    (builtins.hasAttr "rescue-hashedPasswordFile" config.age.secrets)
    {
      hashedPasswordFile =
        config.age.secrets."rescue-hashedPasswordFile".path;
    };
in {
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true; # Normal sudo still asks for password
    extraRules = [
      {
        users = usernameList;
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = ["NOPASSWD"];
          }
          {
            command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
            options = ["NOPASSWD"];
          }
          {
            command = "/run/current-system/bin/switch-to-configuration";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
  users = {
    mutableUsers = true; # Allow commands to change user configurations
    users =
      (builtins.mapAttrs (username: userVars: mkUserConfig username userVars) usersVars)
      // {
        rescue =
          {
            isNormalUser = true;
          }
          // rescuePasswordAttrs;
      };
  };

  nix.settings.allowed-users = usernameList; # Users allowed to connect to the Nix daemon
  nix.settings.trusted-users = usernameList; # Users allowed to change system-level settings, add arbitrary binary caches, etc.,
}
