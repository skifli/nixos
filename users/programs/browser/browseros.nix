{
  inputs,
  pkgs,
  userVars,
  ...
}:

{
  home-manager = {
    users.${userVars.username} = {
      home.packages = [
        inputs.browseros-ai.packages.${pkgs.system}.default
      ];

      /*
      systemd.user.services.browseros = {
        Unit = {
          Description = "BrowserOS";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${inputs.browseros-ai.packages.${pkgs.system}.default}/bin/browseros";
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
