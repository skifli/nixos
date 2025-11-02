{
  lib,
  pkgs,
  userVars,
  ...
}:

{
  services.greetd =
    let
      session = {
        command = lib.mkIf (userVars.programs.compositor == "niri") "${pkgs.uwsm}/bin/uwsm start ${pkgs.niri}/bin/niri-session";
        user = userVars.username;
      };
    in
    # Or can do rec to enable recursive mentioning
    {
      enable = true;
      settings = {
        default_session = session;
        initial_session = session;
      };
    };

  # Unlocks the GPG keyring automatically on login
  # security.pam.services.greetd.enableGnomeKeyring = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = userVars.username;
}
