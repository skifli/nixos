{
  lib,
  pkgs,
  usersVars,
  ...
}: {
  # Services to start
  services = {
    fstrim.enable = true; # Auto SSD trimming of no longer used blocks
    devmon.enable = true; # For auto mounting USB & more (convenience)
    gvfs.enable = true; # Mounting MTP (Android phones), so in general extending devmon
    libinput.enable = true; # Essential standard input driver
    udisks2.enable = true; # Low-level system daemon that manages disks / storage devices
    upower.enable = true;

    # agenix expects SSH host keys to exist for decryption identities.
    # Enabling openssh ensures host keys are managed on NixOS.
    openssh = {
      enable = true;
      openFirewall = false;
    };

    /*
       CAN CAUSE A BUNCH O' PROBLEMS
    # Userspace CPU Scheduler for Improved Latency for Gaming (Hardware Specific)
    scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      scheduler = "scx_bpfland"; # https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
    };
    */
  };

  # KDE service cache refresh.
  # This fixes missing/incorrect desktop integration after rebuilds
  # (for example default app handlers in Dolphin).
  system.activationScripts.kbuildsycoca6-refresh.text = let
    kbuildsycoca6 = "${pkgs.kdePackages.kservice}/bin/kbuildsycoca6";
    users = builtins.attrNames usersVars;
    userCmds = lib.concatStringsSep "\n" (
      map (u: ''
        if [ -x "${kbuildsycoca6}" ] && [ -d "/home/${u}" ]; then
          ${pkgs.util-linux}/bin/runuser -u "${u}" -- "${kbuildsycoca6}" >/dev/null 2>&1 || true
        fi
      '')
      users
    );
  in ''
    # Refresh KDE app cache for enabled users
    ${userCmds}
  '';

  # Weekly hosts blocklist refresh.
  # Run as root (it updates system hosts) but never hard-fail the system.
  systemd.services.hblock-update = {
    description = "Update hblock hosts blocklist";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      if ! ${pkgs.hblock}/bin/hblock; then
        echo "hblock update failed; ignoring" >&2
      fi
      exit 0
    '';
  };

  systemd.timers.hblock-update = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "2h";
      Unit = "hblock-update.service";
    };
  };
}
