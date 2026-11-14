{ config, hostVars, ... }:
let
  # Host-specific radio tuning; defaults are the plain BlueZ defaults.
  tuning = hostVars.bluetooth or { };
in
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = {
        # Advertise as the hostname when pairing from a phone, earbuds, etc.
        Name = config.networking.hostName;

        # Earbuds use Just Works pairing. Let them re-pair after a factory
        # reset without having to delete the stale bond first.
        JustWorksRepairing = "always";

        # Faster inbound reconnects (phone -> PC, keyboards etc.) at the cost of a
        # more aggressive 2.4 GHz page scan. Only worth enabling on hosts whose
        # Wi-Fi doesn't use 2.4 GHz.
        FastConnectable = tuning.fastConnectable or false;
      };

      Policy = {
        # BlueZ defaults made explicit: keep retrying the audio profiles after
        # a link loss instead of giving up immediately.
        ReconnectAttempts = 7;
        ReconnectIntervals = "1,2,4,8,16,32,64";

        # Host-specific: combo cards sharing antennas with Wi-Fi want Wi-Fi to
        # settle after resume before Bluetooth reconnects audio devices.
        ResumeDelay = tuning.resumeDelay or 0;
      };
    };
  };
}
