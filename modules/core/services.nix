{ pkgs, ... }:

{
  # Services to start
  services = {
    # fstrim.enable = true; # Auto SSD trimming of no longer used blocks
    devmon.enable = true; # For auto mounting USB & more (convenience)
    gvfs.enable = true; # Mounting MTP (Android phones), so in general extending devmon
    libinput.enable = true; # Essential standard input driver
    udisks2.enable = true; # Low-level system daemon that manages disks / storage devices

    # Userspace CPU Scheduler for Improved Latency for Gaming (Hardware Specific)
    scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      scheduler = "scx_bpfland"; # https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
    };
  };
}
