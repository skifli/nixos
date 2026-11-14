{ lib, pkgs, hostVars, userVars, ... }:
let
  # Host-supplied ALSA node name for the built-in speakers. Unset on hosts that
  # shouldn't mute anything at login (e.g. the tablet), which disables the unit.
  sinkName = hostVars.builtinSpeakerSink or null;
in
{
  home-manager.users.${userVars.username} = lib.mkIf (sinkName != null) {
    # Mute the built-in speakers once per login, so nothing unexpectedly blasts out.
    #
    # Targets the ALSA sink by node name rather than @DEFAULT_AUDIO_SINK@ on purpose:
    # when Bluetooth headphones connect they become the default sink and keep their own
    # (WirePlumber-restored) volume — this never touches them.
    #
    # It's a oneshot at login, not a loop: unmute during a session and it stays unmuted
    # until the next login.
    systemd.user.services.mute-builtin-speakers = {
      Unit = {
        Description = "Mute built-in speakers at login";
        After = [
          "pipewire.service"
          "wireplumber.service"
          "graphical-session.target"
        ];
        PartOf = [ "graphical-session.target" ];
        Wants = [
          "pipewire.service"
          "wireplumber.service"
        ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = toString (
          pkgs.writeShellScript "mute-builtin-speakers" ''
            sink="${sinkName}"
            wpctl="${pkgs.wireplumber}/bin/wpctl"
            pw_dump="${pkgs.pipewire}/bin/pw-dump"
            jq="${pkgs.jq}/bin/jq"

            # This wpctl build only accepts numeric IDs, so resolve the name each boot.
            find_sink() {
              "$pw_dump" | "$jq" -r --arg n "$sink" \
                '.[] | select(.info.props["node.name"]? == $n) | .id' | head -n1
            }

            id=""
            for _ in $(seq 1 40); do
              id=$(find_sink)
              [ -n "$id" ] && break
              sleep 0.25
            done

            if [ -z "$id" ]; then
              echo "built-in sink not found, leaving volume alone" >&2
              exit 0
            fi

            # Give WirePlumber a moment to restore its saved state first, so our mute sticks.
            sleep 1

            "$wpctl" set-volume "$id" 0
            "$wpctl" set-mute "$id" 1
          ''
        );
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
