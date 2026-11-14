{ pkgs, userVars, ... }:
{
  home-manager.users.${userVars.username} = {
    # TigerVNC ships `vncviewer`, which rdp.sh uses for the Oracle, Pifi, and Pistor
    # targets.
    home.packages = with pkgs; [
      tigervnc
    ];
  };
}
