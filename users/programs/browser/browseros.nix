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
      primaryBrowser = builtins.elemAt userVars.programs.browsers 0;
    in {
      home.packages = [
        browseros
      ];

      xdg.mimeApps.defaultApplications = pkgs.lib.mkIf (primaryBrowser == "browseros") {
        "text/html" = ["browseros.desktop"];
        "x-scheme-handler/http" = ["browseros.desktop"];
        "x-scheme-handler/https" = ["browseros.desktop"];
        "x-scheme-handler/ftp" = ["browseros.desktop"];
        "x-scheme-handler/chrome" = ["browseros.desktop"];
        "x-scheme-handler/about" = ["browseros.desktop"];
        "x-scheme-handler/unknown" = ["browseros.desktop"];
        "application/xhtml+xml" = ["browseros.desktop"];
      };

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
