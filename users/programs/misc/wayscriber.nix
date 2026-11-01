{
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}:
{
  home-manager.users.${userVars.username} = {
    home.packages = [
      pkgsUnstable.wayscriber # Unstable as it is actively developed - stable only has 0.9.19
      pkgs.slurp # Needed by wayscriber's selection screenshot helpers (grim / wl-clipboard already present)

      # The daemon advertises the StatusNotifierItem icon name `wayscriber`, but
      # the package installs no icons of its own, so the tray shows a "missing
      # icon" placeholder. Ship the upstream icons into hicolor under that name.
      (pkgs.runCommand "wayscriber-icons" { } ''
        for size in 16 22 24 64 128; do
          install -Dm644 \
            ${pkgsUnstable.wayscriber.src}/packaging/icons/wayscriber-$size.png \
            $out/share/icons/hicolor/''${size}x''${size}/apps/wayscriber.png
        done
      '')
    ];

    # Keep the wayscriber daemon running so the overlay toggles instantly
    systemd.user.services.wayscriber = {
      Unit = {
        Description = "Wayscriber screen annotation daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgsUnstable.wayscriber}/bin/wayscriber --daemon";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
