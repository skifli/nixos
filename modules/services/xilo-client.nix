{
  config,
  lib,
  userVars,
  ...
}:

{
  # Xilo binary cache authentication
  # Use systemd-tmpfiles to create the netrc file from agenix secret
  systemd.tmpfiles.rules = lib.mkIf (config.age.secrets.xilo-netrc != null) [
    "C+ /home/${userVars.username}/.netrc 0600 ${userVars.username} users - ${
      config.age.secrets."xilo-netrc".path
    }"
  ];
}
