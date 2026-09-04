{
  hostVars,
  pkgs,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = { lib, ... }: {
    home.packages = with pkgs; [
      sunsetr
    ];

    systemd.user.services.sunsetr = {
      Unit = {
        Description = "Sunsetr daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.sunsetr}/bin/sunsetr";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    home.activation.setSunsetrCoordinates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        TARGET_FILE="$HOME/.config/sunsetr/sunsetr.toml"
        mkdir -p "$(dirname "$TARGET_FILE")"

        if [ ! -f "$TARGET_FILE" ]; then
          cat << 'EOF' > "$TARGET_FILE"
      latitude = ${toString hostVars.latitude}
      longitude = ${toString hostVars.longitude}
      EOF
        else
          sed -i 's/^latitude.*/latitude = ${toString hostVars.latitude}/' "$TARGET_FILE"
          sed -i 's/^longitude.*/longitude = ${toString hostVars.longitude}/' "$TARGET_FILE"
        fi
    '';
  };
}
