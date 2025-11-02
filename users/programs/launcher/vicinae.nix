{
  inputs,
  lib,
  pkgs,
  userVars,
  ...
}:

{

  home-manager = {
    sharedModules = [ inputs.vicinae.homeManagerModules.default ];

    users.${userVars.username} = {
      services.vicinae = {
        enable = true;
        autoStart = true;
        settings = {
          faviconService = "twenty"; # twenty | google | none
          font.size = 9.0;

          popToRootOnClose = true; # Go back to initial root view after close
          rootSearch.searchFiles = true;

          window = {
            csd = true; # Looks better with it heh

            opacity = 0.95;
            rounding = 10;
          };
        };
      };

      systemd.user.services.vicinae = {
        Unit = {
          Description = "Vicinae server daemon";
          Documentation = [ "https://docs.vicinae.com" ];
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
          BindsTo = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${inputs.vicinae.packages.${pkgs.system}.default}/bin/vicinae server";
          Restart = "always";
          RestartSec = lib.mkDefault "5";
          KillMode = "process";
          Environment = "USE_LAYER_SHELL=1";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
