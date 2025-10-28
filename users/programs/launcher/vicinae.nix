{ inputs, userVars, ... }:

{

  home-manager = {
    sharedModules = [ inputs.vicinae.homeManagerModules.default ];

    users.${userVars.username} = {
      services.vicinae = {
        enable = true;
        autoStart = true;
        settings = {
          faviconService = "twenty"; # twenty | google | none
          # font.size = 11;
          popToRootOnClose = true; # Go back to initial root view after close
          rootSearch.searchFiles = true;
          # theme.name = "vicinae-dark";
          window = {
            csd = true;
            opacity = 0.95;
            rounding = 10;
          };
        };
      };
    };
  };
}
