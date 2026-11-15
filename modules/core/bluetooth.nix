{
  config,
  hostVars,
  lib,
  pkgs,
  ...
}:
let
  # Host-specific radio tuning; defaults are the plain BlueZ defaults.
  tuning = hostVars.bluetooth or { };

  # BlueZ only asks for per-service authorisation (Wayle's "allow audio
  # streaming / remote control" prompt) on untrusted devices. Trusting paired
  # devices makes reconnects silent.
  trustPairedDevices = pkgs.writeShellScript "trust-paired-bluetooth" ''
    set -u

    bluetoothctl="${pkgs.bluez}/bin/bluetoothctl"
    grep="${pkgs.gnugrep}/bin/grep"

    "$bluetoothctl" devices Paired |
      while read -r _ mac _; do
        [ -n "$mac" ] || continue

        if ! "$bluetoothctl" info "$mac" | "$grep" -q 'Trusted: yes'; then
          "$bluetoothctl" trust "$mac" >/dev/null 2>&1 || true
        fi
      done
  '';

  general = {
    Name = config.networking.hostName;
    JustWorksRepairing = "always";
  }
  // lib.optionalAttrs (tuning ? fastConnectable) {
    FastConnectable = tuning.fastConnectable or false;
  };

  policy = {
    # BlueZ defaults made explicit: keep retrying the audio profiles after
    # a link loss instead of giving up immediately.
    ReconnectAttempts = 7;
    ReconnectIntervals = "1,2,4,8,16,32,64";
  }
  // lib.optionalAttrs (tuning ? resumeDelay) {
    # Lets Wi-Fi settle on combo cards before Bluetooth reconnects audio.
    ResumeDelay = tuning.resumeDelay or 0;
  };
in
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = general;
      Policy = policy;
    };
  };

  # Sweep at boot and periodically so devices paired through Wayle (which
  # does not trust them) stop asking for service authorization.
  systemd.services.bluetooth-trust-paired = {
    description = "Trust paired Bluetooth devices";
    wants = [ "bluetooth.service" ];
    after = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "60s";
      ExecStart = trustPairedDevices;
    };
  };

  systemd.timers.bluetooth-trust-paired = {
    description = "Periodically trust newly paired Bluetooth devices";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "bluetooth-trust-paired.service";
      OnBootSec = "30s";
      OnUnitActiveSec = "2min";
      AccuracySec = "10s";
    };
  };
}
