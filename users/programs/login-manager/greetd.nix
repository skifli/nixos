{
  pkgs,
  userVars,
  ...
}:

{
  services.greetd =
    let
      session = {
        command =
          "${pkgs.uwsm}/bin/uwsm start "
          + (
              if userVars.programs.compositor == "niri"
              then "${pkgs.niri}/bin/niri-session"
              else "${pkgs.${userVars.programs.compositor}}/bin/${userVars.programs.compositor}"
            );
        user = userVars.username;
      };
    in
    # Or can do rec to enable recursive mentioning
    {
      enable = true;
      settings = {
        default_session = session;
        # initial_session = session;
      };
    };

  # Unlocks the GPG keyring automatically on login
  # security.pam.services.greetd.enableGnomeKeyring = true;

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = userVars.username;
}
