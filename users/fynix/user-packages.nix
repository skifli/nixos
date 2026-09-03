{
  inputs,
  lib,
  userVars,
  pkgs,
  pkgsUnstable,
  ...
}: let
  shell-preload = pkgs.writeShellScript "shell-preload" ''
    set -u
    zsh_bin="$1"
    ${pkgs.coreutils}/bin/dd if="$zsh_bin" of=/dev/null bs=1M status=none 2>/dev/null
    for lib in $(${pkgs.glibc.bin}/bin/ldd "$zsh_bin" 2>/dev/null | ${pkgs.gawk}/bin/awk '/=>/ && /nix\/store/ {print $3}'); do
      [ -f "$lib" ] && ${pkgs.coreutils}/bin/dd if="$lib" of=/dev/null bs=1M status=none 2>/dev/null
    done
  '';
in {
  home-manager.sharedModules = [
    inputs.fyde-nix.homeManagerModules.wayle
    inputs.fyde-nix.homeManagerModules.swayidle
  ];

  home-manager.users.${userVars.username} = {
    services.wayle.settings.wallpaper.engine-enabled = lib.mkForce false;

    # Include an input override file that the rotation daemon updates
    # with the correct touch/tablet calibration-matrix for the current orientation.
    wayland.windowManager.niri.extraConfig = ''
      include "input-override.kdl"
    '';

    # Input override file for the niri rotation daemon.
    # niri includes this via the `include "input-override.kdl"` line added
    # through extraConfig above. The rotation daemon replaces this symlink with
    # a regular file containing the calibration-matrix for the current orientation.
    xdg.configFile."niri/input-override.kdl" = {
      text = ''
        input {
          touch {
            map-to-output "DSI-1"
            calibration-matrix 0.0 -1.0 1.0 1.0 0.0 0.0
          }

          tablet {
            map-to-output "DSI-1"
            calibration-matrix 0.0 -1.0 1.0 1.0 0.0 0.0
          }
        }
      '';
    };

    # niri-native auto-rotation daemon (user level, graphical session).
    # The DSI panel is natively portrait (touch X:0-1599, Y:0-2559) but driven
    # landscape. niri is smithay-based (NOT wlroots): map-to-output does NOT
    # rotate touch/tablet with the output transform. This daemon reads
    # monitor-sensor (accelerometer), rotates the niri output, and writes the
    # matching touch/tablet calibration-matrix to ~/.config/niri/input-override.kdl.
    systemd.user.services.niri-rotate = {
      Unit = {
        Description = "niri-native auto-rotation daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "2";
        Environment = "PATH=${pkgs.lib.makeBinPath [
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.niri
          pkgs.iio-sensor-proxy
        ]}:/run/current-system/sw/bin:/etc/profiles/per-user/${userVars.username}/bin";
        ExecStart = pkgs.writeShellScript "niri-rotate" ''
                    set -euo pipefail

                    OVERRIDE="$HOME/.config/niri/input-override.kdl"
                    MONITOR_SENSOR="${pkgs.iio-sensor-proxy}/bin/monitor-sensor"

                    # If the file is an HM symlink, break it so we can write normally
                    if [ -L "$OVERRIDE" ]; then
                      cp --remove-destination "$(readlink -f "$OVERRIDE")" "$OVERRIDE"
                    fi

                    write_override() {
                      local cal="$1"
                      cat > "$OVERRIDE" <<ENDOFKDL
          input {
            touch {
              map-to-output "DSI-1"
              calibration-matrix $cal
            }

            tablet {
              map-to-output "DSI-1"
              calibration-matrix $cal
            }
          }
          ENDOFKDL
                    }

                    # The panel is natively portrait: touch X:0-1599 Y:0-2559
                    # niri transform values: normal=0, 90cw=1, 180=2, 270cw=3
                    get_transform_and_cal() {
                      case "$1" in
                        *normal*)
                          CAL="1.0 0.0 0.0 0.0 1.0 0.0"
                          TRANSFORM=0
                          ;;
                        *left-up*)
                          # Tablet held landscape, left side up -> 90° CW
                          CAL="0.0 -1.0 1.0 1.0 0.0 0.0"
                          TRANSFORM=1
                          ;;
                        *inverted*)
                          # Upside down -> 180°
                          CAL="-1.0 0.0 1.0 0.0 -1.0 1.0"
                          TRANSFORM=2
                          ;;
                        *right-up*)
                          # Tablet held landscape, right side up -> 270° CW (default)
                          CAL="0.0 1.0 0.0 -1.0 0.0 1.0"
                          TRANSFORM=3
                          ;;
                        *)
                          return 1
                          ;;
                      esac
                    }

                    echo "niri-rotate: starting monitor-sensor..."

                    $MONITOR_SENSOR 2>/dev/null | while IFS= read -r line; do
                      orientation=$(echo "$line" | grep -oP 'Orientation:\s*\K\S+' || true)
                      if [ -z "$orientation" ]; then
                        continue
                      fi

                      if get_transform_and_cal "$orientation"; then
                        niri msg output DSI-1 transform "$TRANSFORM" 2>/dev/null || true
                        write_override "$CAL"
                        echo "niri-rotate: orientation=$orientation transform=$TRANSFORM"
                      fi
                    done

                    echo "niri-rotate: monitor-sensor exited, restarting..."
                    exit 1
        '';
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    # Launch startup apps via a user service rather than niri's
    # spawn-sh-at-startup. At boot, niri reads its config before a slow
    # first-login home-manager activation has rewritten it, so it often starts
    # with a stale config and the startup apps never spawn. A user service
    # forced after the graphical session properly runs once niri is up.
    systemd.user.services.apps-startup = {
      Unit = {
        Description = "Launch ${userVars.username} startup applications";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "PATH=${pkgs.lib.makeBinPath [
          pkgs.bash
          pkgs.jq
          pkgs.niri
          pkgs.libnotify
          pkgsUnstable.nirius
          pkgs.libsecret
          pkgs.systemd
        ]}:/run/current-system/sw/bin:/etc/profiles/per-user/${userVars.username}/bin";
        ExecStart = "${pkgs.bash}/bin/bash /home/${userVars.username}/.local/bin/startup.sh";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    systemd.user.services.shell-preload = {
      Unit = {
        Description = "Warm shell page cache";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${shell-preload} /etc/profiles/per-user/${userVars.username}/bin/zsh";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
