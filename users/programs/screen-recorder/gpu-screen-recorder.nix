{
  pkgs,
  userVars,
  ...
}: {
  programs.gpu-screen-recorder.enable = true; # For promptless recording on both CLI and GUI

  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      gpu-screen-recorder-gtk # GUI app
    ];
  };
}
