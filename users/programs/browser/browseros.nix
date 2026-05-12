{
  inputs,
  pkgs,
  userVars,
  ...
}: {
  home-manager = {
    users.${userVars.username} = let
      system = pkgs.stdenv.hostPlatform.system;
      browseros = inputs.browseros-ai.packages.${system}.default;
    in {
      home.packages = [
        browseros
      ];

      /*
      systemd.user.services.browseros = {
        Unit = {
          Description = "BrowserOS";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${browseros}/bin/browseros";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
      */
    };
  };
}
