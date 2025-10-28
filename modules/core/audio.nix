{ pkgs, ... }:

{
  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      }; # Run an ALSA compatibility layer

      jack.enable = true; # Run a JACK compatibility layer
      pulse.enable = true; # Run a PulseAudio-compatible daemon
    };

    pulseaudio.enable = false; # Disable in favour of pipewire
  };

  environment.systemPackages = with pkgs; [ pavucontrol ]; # GUI
}
