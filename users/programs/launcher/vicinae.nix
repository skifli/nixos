{
  inputs,
  lib,
  userVars,
  ...
}:

{

  home-manager = {
    sharedModules = [ inputs.vicinae.homeManagerModules.default ];

    users.${userVars.username} = {
      programs.vicinae = {
        enable = true;
        systemd = {
          autoStart = true;
          enable = true;
        };
        settings = {
          faviconService = "twenty"; # twenty | google | none
          font.size = 9.0;

          popToRootOnClose = true; # Go back to initial root view after close
          rootSearch.searchFiles = true;

          window = {
            csd = true; # Looks better with it heh

            opacity = lib.mkForce 0.95;
            rounding = 10;
          };
        };
      };
    };
  };
}
