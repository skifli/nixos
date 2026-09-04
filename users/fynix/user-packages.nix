{
  inputs,
  lib,
  userVars,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  shell-preload = pkgs.writeShellScript "shell-preload" ''
    set -u
    zsh_bin="$1"
    ${pkgs.coreutils}/bin/dd if="$zsh_bin" of=/dev/null bs=1M status=none 2>/dev/null
    for lib in $(${pkgs.glibc.bin}/bin/ldd "$zsh_bin" 2>/dev/null | ${pkgs.gawk}/bin/awk '/=>/ && /nix\/store/ {print $3}'); do
      [ -f "$lib" ] && ${pkgs.coreutils}/bin/dd if="$lib" of=/dev/null bs=1M status=none 2>/dev/null
    done
  '';
in
{
  home-manager.sharedModules = [
    inputs.fyde-nix.homeManagerModules.wayle
    inputs.fyde-nix.homeManagerModules.swayidle
  ];

  home-manager.users.${userVars.username} = {
    services.wayle.settings.wallpaper.engine-enabled = lib.mkForce false;

    fydetabShell.wayle.autoRotate = {
      statusCommand = ''systemctl --user is-active niri-rotate >/dev/null 2>&1 && printf '{"state":"On"}' || printf '{"state":"Off"}' '';
      toggleCommand = ''
        if systemctl --user is-active niri-rotate >/dev/null 2>&1; then
          systemctl --user stop niri-rotate
          notify-send -a wayle -u low -t 2500 "Auto-rotate" "Auto-rotate disabling..."
        else
          systemctl --user start niri-rotate
          notify-send -a wayle -u low -t 2500 "Auto-rotate" "Auto-rotate enabling..."
        fi
      '';
    };

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
            calibration-matrix 0.0 -1.0 1.0 1.0 0.0 0.0;
            map-to-output "DSI-1";
          }

          tablet {
            map-to-output "DSI-1";
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
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "2";
        Environment = "PATH=${
          pkgs.lib.makeBinPath [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.niri
            pkgs.iio-sensor-proxy
          ]
        }:/run/current-system/sw/bin:/etc/profiles/per-user/${userVars.username}/bin";
        ExecStart = pkgs.writeShellScript "niri-rotate" ''
                              set -euo pipefail

                              MONITOR_SENSOR="${pkgs.iio-sensor-proxy}/bin/monitor-sensor"

                              # Find the niri socket (PID changes on restart)
                              find_niri_socket() {
                                for f in "$XDG_RUNTIME_DIR"/niri.wayland-*.sock; do
                                  [ -S "$f" ] && { NIRI_SOCKET="$f"; export NIRI_SOCKET; return 0; }
                                done
                                return 1
                              }

                              find_niri_socket || { echo "niri-rotate: no niri socket found"; exit 1; }

                              get_transform() {
                                case "$1" in
                                  *normal*)    echo normal ;;
                                  *left-up*)   echo 90 ;;
                                  *right-up*)  echo 270 ;;
                                  *bottom-up*) echo 180 ;;
                                  *)           return 1 ;;
                                esac
                              }

                              # niri 26.04 does NOT apply the output transform to
                              # map-to-output'd touch/tablet. We therefore write the
                              # matching calibration-matrix for each orientation.
                              # Matrices use normalised [0,1] touch coords:
                              #   new_x = a*x + b*y + c,  new_y = d*x + e*y + f
                              get_calibration() {
                                case "$1" in
                                  normal) echo "1.0 0.0 0.0 0.0 1.0 0.0" ;;      # landscape (identity)
                                  90)     echo "0.0 1.0 0.0 -1.0 0.0 1.0" ;;     # left-up
                                  180)    echo "-1.0 0.0 1.0 0.0 -1.0 1.0" ;;    # bottom-up
                                  270)    echo "0.0 -1.0 1.0 1.0 0.0 0.0" ;;     # right-up
                                  *) return 1 ;;
                                esac
                              }

                              write_input_override() {
                                local matrix="$1"
                                rm -f "$HOME/.config/niri/input-override.kdl"
                                cat > "$HOME/.config/niri/input-override.kdl" <<OVERRIDE
          input {
            touch {
              calibration-matrix ''${matrix};
              map-to-output "DSI-1";
            }
            tablet {
              map-to-output "DSI-1";
            }
          }
          OVERRIDE
                              }

                              echo "niri-rotate: starting monitor-sensor (socket=$NIRI_SOCKET)..."

                              # monitor-sensor block-buffers its stdout when piped
                              # (GLib only line-buffers on a TTY); tdbuf forces
                              # line-buffering so show
                              stdbuf -oL $MONITOR_SENSOR --accel 2>/dev/null | while IFS= read -r line; do
                                orientation=$(echo "$line" | grep -ioP 'orientation changed(?:\s*to)?:\s*\K[a-z-]+' || true)
                                if [ -z "$orientation" ]; then
                                  continue
                                fi

                                TRANSFORM=$(get_transform "$orientation") || continue
                                MATRIX=$(get_calibration "$TRANSFORM") || continue
                                write_input_override "$MATRIX"
                                niri msg output DSI-1 transform "$TRANSFORM" 2>/dev/null || true
                                niri msg action load-config-file 2>/dev/null || true
                                echo "niri-rotate: orientation=$orientation transform=$TRANSFORM matrix=$MATRIX"
                              done

                              echo "niri-rotate: monitor-sensor exited, restarting..."
                              exit 1
        '';
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Launch startup apps via a user service rather than niri's
    # spawn-sh-at-startup. At boot, niri reads its config before a slow
    # first-login home-manager activation has rewritten it, so it often starts
    # with a stale config and the startup apps never spawn. A user service
    # forced after the graphical session properly runs once niri is up.
    systemd.user.services.apps-startup = {
      Unit = {
        Description = "Launch ${userVars.username} startup applications";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "PATH=${
          pkgs.lib.makeBinPath [
            pkgs.bash
            pkgs.jq
            pkgs.niri
            pkgs.libnotify
            pkgsUnstable.nirius
            pkgs.libsecret
            pkgs.systemd
          ]
        }:/run/current-system/sw/bin:/etc/profiles/per-user/${userVars.username}/bin";
        ExecStart = "${pkgs.bash}/bin/bash /home/${userVars.username}/.local/bin/startup.sh";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.shell-preload = {
      Unit = {
        Description = "Warm shell page cache";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${shell-preload} /etc/profiles/per-user/${userVars.username}/bin/zsh";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
