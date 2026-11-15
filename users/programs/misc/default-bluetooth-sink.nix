{
  pkgs,
  userVars,
  ...
}:
let
  # `pw-mon -p` prints one blank-line-separated paragraph per event. This picks
  # out newly added Bluetooth sink nodes and prints "<id>\t<node.name>".
  parseBluetoothSink = pkgs.writeText "default-bluetooth-sink.awk" ''
    BEGIN { RS = "" }

    /^added:/ &&
    /type: PipeWire:Interface:Node/ &&
    /media\.class = "Audio\/Sink"/ &&
    /node\.name = "bluez_output\./ {
      match($0, /id: [0-9]+/)
      id = substr($0, RSTART + 4, RLENGTH - 4)
      match($0, /node\.name = "[^"]+"/)
      name = substr($0, RSTART, RLENGTH)
      sub(/^node\.name = "/, "", name)
      sub(/"$/, "", name)
      print id "\t" name
      fflush()
    }
  '';
in
{
  home-manager.users.${userVars.username} = {
    # WirePlumber restores the last manually selected sink, so a freshly
    # connected Bluetooth sink does not become the default on its own.
    # Select every new bluez_output.* sink explicitly. Manual changes made
    # while it is connected are left alone; it is only reasserted on arrival.
    systemd.user.services.default-bluetooth-sink = {
      Unit = {
        Description = "Make a newly connected Bluetooth device the default audio sink";
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
        Type = "simple";
        Restart = "always";
        RestartSec = 2;

        ExecStart = toString (
          pkgs.writeShellScript "default-bluetooth-sink" ''
            set -u

            pw_mon="${pkgs.pipewire}/bin/pw-mon"
            wpctl="${pkgs.wireplumber}/bin/wpctl"
            awk="${pkgs.gawk}/bin/awk"

            while true; do
              "$pw_mon" -p -N 2>/dev/null |
                "$awk" -f "${parseBluetoothSink}" |
                while IFS=$'\t' read -r id name; do
                  [ -n "$id" ] || continue

                  # A node may not be ready the instant it is announced.
                  for _ in 1 2 3 4 5; do
                    if "$wpctl" set-default "$id" >/dev/null 2>&1; then
                      echo "Default audio sink -> $name (id $id)"
                      break
                    fi
                    sleep 1
                  done
                done

              echo "PipeWire monitor exited; reconnecting..."
              sleep 2
            done
          ''
        );
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
