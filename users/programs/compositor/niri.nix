{
  hostVars,
  inputs,
  pkgs,
  userVars,
  ...
}@attrs:

{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ]; # Add Niri overlay

  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri.homeModules.niri
      ];

      # Niri automagically sets up a lot of needed stuff
      programs.niri = {
        enable = true;
        settings = {
          binds = import ./niri/binds.nix attrs;
          outputs = hostVars.outputs;
          workspaces = hostVars.workspaces;
          spawn-at-startup = [ ];
        };
      };

      # Environment variables for Niri
      home = {
        sessionVariables.XDG_CURRENT_DESKTOP = "niri";
        sessionVariables.XDG_SESSION_DESKTOP = "niri";

        packages = with pkgs; [
          swaybg

          # X11 compatability for Wayland
          xwayland-satellite
        ];
      };

      /*
        # NOT NEEDED ANYMORE: NIRI JUST REQUIRES IT TO BE INSTALLED, IT DOES THE REST
        # Switch from `Install.WantedBy = [ "graphical-session.target" ]` as defined
        # in the service file provided by the xwayland-satellite package. This links
        # xwayland-satellite to niri specifically, and schedules it so that there is
        # a wayland session available when it starts.
        systemd.user.services.xwayland-satellite = {
          Unit = {
            Description = "Xwayland outside your Wayland";
            BindsTo = "graphical-session.target";
            PartOf = "graphical-session.target";
            After = "graphical-session.target";
            Requisite = "graphical-session.target";
          };
          Service = {
            Type = "notify";
            NotifyAccess = "all";
            ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
            StandardOutput = "journal";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      */
    };
  };

  xdg.portal.configPackages = [ pkgs.niri ];
}
