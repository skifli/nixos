{
  userVars,
  ...
}:

{
  services.earlyoom = {
    enable = true;
    freeMemKillThreshold = 5; # Kill when <5% memory left
    freeMemThreshold = 10; # Request graceful shutdown when <10% memory left
    freeSwapKillThreshold = 15; # Kill when <15% swap left
    freeSwapThreshold = 20; # Request graceful shutdown when <20% memory left
    enableNotifications = true;
    extraArgs =
      let
        nonEmpty = builtins.filter (p: p != null && p != "");

        wrapEach = patterns: map (p: "(${p})") patterns;

        prefer = wrapEach (nonEmpty [
          userVars.programs.browser
        ]);

        avoid = wrapEach (nonEmpty [
          "sshd"
          "systemd"
          "systemd-logind"
          "systemd-udevd"
          userVars.programs.bar
          userVars.programs.compositor
          userVars.programs.display-server
          userVars.programs.idler
          userVars.programs.login-manager
          userVars.programs.notifications
          userVars.programs.osd
          userVars.programs.prompt
          userVars.programs.shell
          userVars.programs.terminal
        ]);

        mkRegex = pats: "^(" + builtins.concatStringsSep "|" pats + ")$";
      in
      (
        if prefer == [ ] then
          [ ]
        else
          [
            "--prefer"
            (mkRegex prefer)
          ]
      )
      ++ (
        if avoid == [ ] then
          [ ]
        else
          [
            "--avoid"
            (mkRegex avoid)
          ]
      );
  };
}
