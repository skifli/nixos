{
  pkgs,
  userVars,
  ...
}:
let
  python3 = pkgs.python3;

  qwarp = python3.pkgs.buildPythonApplication rec {
    pname = "qwarp";
    version = "0.9.4";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "iashutoshtiwari";
      repo = "qwarp";
      rev = "v${version}";
      hash = "sha256-YXik9BGndmhOrJDza5Eo2kAt+yHv9jJgvkHKVsTknGg=";
    };

    build-system = with python3.pkgs; [
      setuptools
      wheel
    ];
    dependencies = [ python3.pkgs.pyqt6 ];

    pythonImportsCheck = [ "qwarp" ];

    meta = with pkgs.lib; {
      description = "Qt6-based alternative desktop client for Cloudflare WARP";
      homepage = "https://github.com/iashutoshtiwari/qwarp";
      license = licenses.mit;
      platforms = platforms.linux;
      mainProgram = "qwarp";
    };
  };
in
{
  home-manager.users.${userVars.username} = {
    home.packages = [ qwarp ];

    systemd.user.services.qwarp = {
      Unit = {
        Description = "QWarp - Cloudflare WARP GUI";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${qwarp}/bin/qwarp --start-minimized";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
