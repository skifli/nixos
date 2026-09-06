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

  stylusTouchPython = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.evdev ]);
in
{
  home-manager.sharedModules = [
    inputs.fyde-nix.homeManagerModules.wayle
    inputs.fyde-nix.homeManagerModules.swayidle
  ];

  home-manager.users.${userVars.username} = {
    services.wayle.settings = {
      # We use custom one cus Niri mhm
      wallpaper.engine-enabled = lib.mkForce false;

      modules.custom = lib.mkAfter [
        {
          id = "stylus-touch";
          mode = "poll";
          interval-ms = 1000;
          command = ''
            systemctl --user is-active --quiet stylus-touch-arbitration.service && printf '{"state":"On"}' || printf '{"state":"Off"}'
          '';
          left-click = ''
            if systemctl --user is-active --quiet stylus-touch-arbitration.service; then
              systemctl --user stop stylus-touch-arbitration.service
              notify-send -a wayle -u low -t 2500 "Stylus touch" "Touch arbitration disabled"
            else
              systemctl --user start stylus-touch-arbitration.service
              notify-send -a wayle -u low -t 2500 "Stylus touch" "Touch arbitration enabled"
            fi
          '';
          on-action = ''
            systemctl --user is-active --quiet stylus-touch-arbitration.service && printf '{"state":"On"}' || printf '{"state":"Off"}'
          '';
          format = "{{ state }}";
          icon-name = "input-tablet-symbolic";
          icon-color = "fg-default";
          label-color = "fg-default";
        }
      ];
    };

    fydetabShell.wayle = {
      # Again custom one cus Niri
      autoRotate = {
        statusCommand = ''systemctl --user is-active niri-rotate >/dev/null 2>&1 && printf '{"state":"On"}' || printf '{"state":"Off"}' '';
        toggleCommand = ''
          if systemctl --user is-active niri-rotate >/dev/null 2>&1; then
            systemctl --user stop niri-rotate
            notify-send -a niri -i "/home/${userVars.username}/.local/share/misc/niri-icon.svg" -u low -t 2500 "Auto-rotate" "Auto-rotate disabling..."
          else
            systemctl --user start niri-rotate
            notify-send -a niri -i "/home/${userVars.username}/.local/share/misc/niri-icon.svg" -u low -t 2500 "Auto-rotate" "Auto-rotate enabling..."
          fi
        '';
      };

      bar = {
        left = [
          "dashboard"
          "clock"
          "custom-auto-rotate"
          "custom-tablet-mode"
          "custom-stylus-touch" # New!
          "systray"
        ];
      };
    };

    # New!
    systemd.user.services.stylus-touch-arbitration = {
      Unit = {
        Description = "Suppress touchscreen input while the stylus is in proximity";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${stylusTouchPython}/bin/python ${./scripts/stylus-touch-arbitration.py}";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # Include an input override file that the rotation daemon updates
    # with the correct tablet calibration-matrix for the current orientation.
    # (touch needs no calibration: niri transforms touch with the output itself)
    wayland.windowManager.niri.extraConfig = ''
      include "input-override.kdl"
    '';

    # Input override file for the niri rotation daemon.
    # niri includes this via the `include "input-override.kdl"` line added
    # through extraConfig above. The rotation daemon replaces this symlink with
    # a regular file containing the calibration-matrix for the current orientation.
    #
    # NOTE: the tablet section deliberately omits `map-to-output`. niri applies
    # aspect-ratio correction for some reasons to tablets that are mapped to an
    # output, which stretches the stylus Y axis ~1.5x on this portrait-panel
    # digitiser (himax-stylus 60x154mm vs DSI-1 0.625 inverted aspect). Without
    # map-to-output, keep_ratio is disabled and the calibration matrix does
    # the rotation itself, so the stylus tracks the output 1:1 in all orientations.
    # touch uses NO calibration-matrix: niri already transforms touch with the
    # output (unlike tablets), which is gud.
    xdg.configFile."niri/input-override.kdl" = {
      text = ''
        input {
          tablet {
            calibration-matrix 0.0 1.0 0.0 -1.0 0.0 1.0;
          }
        }
      '';
    };

    # The DSI panel is natively portrait (touch X:0-1599, Y:0-2559) but driven
    # landscape. niri's touch option applies the output transform itself (so touch
    # needs no calibration), but tablets do NOT follow the transform, so this
    # daemon reads monitor-sensor (accelerometer), rotates the niri output, and
    # writes the matching tablet calibration-matrix to ~/.config/niri/input-override.kdl.
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

                              # Magic numbers
                              get_transform() {
                                case "$1" in
                                  *normal*)   echo 90 ;;
                                  *left-up*)  echo 180 ;;
                                  *right-up*) echo normal ;;
                                  *bottom-up*) echo 270 ;;
                                  *)          return 1 ;;
                                esac
                              }

                              # niri's tablet logic (compute_tablet_position):
                              #   - with  map-to-output: applies output transform
                              #     AND its own aspect-ratio correction, which
                              #     over-stretches this stylus Y axis ~1.5x.
                              #   - without map-to-output: Transform::Normal + no
                              #     aspect correction (keep_ratio=false), so the
                              #     calibration matrix on its own maps the physical
                              #     portrait digitiser to the logical output.
                              # We therefore key the matrix to the SAME orientation
                              # that get_transform chooses for the output transform.
                              # Matrices use normalised [0,1] touch coords:
                              #   new_x = a*x + b*y + c,  new_y = d*x + e*y + f
                              get_calibration() {
                                  # linked to niri transform values returned by get_transform
                                  # (sensor "right-up"->normal, "normal"->90, "left-up"->180, "bottom-up"->270)
                                  # matrices validated live on the fydetab stylus (himax-stylus)
                                  case "$1" in
                                    normal) echo "0.0 1.0 0.0 -1.0 0.0 1.0" ;;  # sensor right-up (landscape)
                                    90)     echo "1.0 0.0 0.0 0.0 1.0 0.0" ;;  # sensor normal
                                    180)    echo "0.0 -1.0 1.0 1.0 0.0 0.0" ;;  # sensor left-up
                                    270)    echo "-1.0 0.0 1.0 0.0 -1.0 1.0" ;;  # sensor bottom-up
                                  *) return 1 ;;
                                esac
                              }

                              write_input_override() {
                                local matrix="$1"
                                rm -f "$HOME/.config/niri/input-override.kdl"
                                cat > "$HOME/.config/niri/input-override.kdl" <<OVERRIDE
          input {
            tablet {
              calibration-matrix ''${matrix};
            }
          }
          OVERRIDE
                              }

                              apply_orientation() {
                                local orientation="$1"
                                local transform matrix

                                transform=$(get_transform "$orientation") || return 0
                                matrix=$(get_calibration "$transform") || return 0
                                write_input_override "$matrix"

                                niri msg output DSI-1 transform "$transform" 2>/dev/null || true
                                niri msg action load-config-file 2>/dev/null || true

                                # awww renders the wallpaper once for the landscape
                                # output; after a transform change it then keeps the
                                # old size and look stretched, so re-request it and
                                # it crops to the new (rotated) output geometry.
                                "${pkgs.awww}/bin/awww" img "$HOME/.local/share/wallpaper" 2>/dev/null || true
                                "${pkgs.awww}/bin/awww" img --namespace overview "$HOME/.local/share/wallpaper-blurred" 2>/dev/null || true

                                echo "niri-rotate: orientation=$orientation transform=$transform matrix=$matrix"
                              }

                              LAST_ORIENTATION=""

                              echo "niri-rotate: starting monitor-sensor (socket=$NIRI_SOCKET)..."

                              # monitor-sensor block-buffers its stdout when piped
                              # (GLib only line-buffers on a TTY); tdbuf forces
                              # line-buffering to show.
                              #
                              # iio-sensor-proxy's orientation is only meaningful
                              # while the device is upright: flat/face-down/face-up
                              # states report arbitrary values that would rotate the
                              # screen wrongly. We therefore ignore orientation
                              # unless the tilt is upright, and re-apply the last
                              # upright orientation when the device is stood back up.
                              stdbuf -oL $MONITOR_SENSOR --accel 2>/dev/null | while IFS= read -r line; do
                                if echo "$line" | grep -qi 'Tilt changed:'; then
                                  the_tilt=$(echo "$line" | grep -ioP 'Tilt changed:\s*\K[a-z-]+' || true)

                                  case "$the_tilt" in
                                    face-down|face-up|flat) upright=0 ;;
                                    *)                      upright=1 ;;
                                  esac
                                  if [ "$upright" != "''${upright_prev:-}" ]; then
                                    upright_prev=$upright

                                    if [ "$upright" = "1" ] && [ -n "$LAST_ORIENTATION" ]; then
                                      echo "niri-rotate: tilt=$the_tilt, resync orientation=$LAST_ORIENTATION"
                                      apply_orientation "$LAST_ORIENTATION"
                                    fi
                                  fi
                                  continue
                                fi

                                orientation=$(echo "$line" | grep -ioP 'orientation changed(?:\s*to)?:\s*\K[a-z-]+' || true)

                                if [ -z "$orientation" ]; then
                                  continue
                                fi

                                if [ "''${upright_prev:-1}" = "1" ]; then
                                  LAST_ORIENTATION=$orientation
                                  apply_orientation "$orientation"
                                else
                                  echo "niri-rotate: ignoring orientation=$orientation (device not upright)"
                                fi
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
