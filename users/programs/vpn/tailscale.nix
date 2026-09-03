{
  config,
  pkgs,
  userVars,
  ...
}: {
  environment.systemPackages = with pkgs; [ktailctl];

  services.tailscale = {
    enable = true;

    useRoutingFeatures = "client";
  };

  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;

    # Fix firewall issues
    checkReversePath = "loose";

    # Always allow traffic from your Tailscale network
    trustedInterfaces = ["tailscale0"];

    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [config.services.tailscale.port];
  };

  # Force tailscaled to use nftables (needed for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # Prevent systemd from waiting for network online
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  home-manager.users.${userVars.username} = {lib, ...}: {
    systemd.user.services.ktailctl = {
      Unit = {
        Description = "KTailctl system tray applet";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.ktailctl}/bin/ktailctl";
        Restart = "on-failure";
        RestartSec = "2s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    home.activation.setKTailctlConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
            TARGET_FILE="$HOME/.config/KTailctlrc"
            mkdir -p "$(dirname "$TARGET_FILE")"

            if [ ! -f "$TARGET_FILE" ]; then
              cat << 'EOF' > "$TARGET_FILE"
      [Interface]
      peerFilter=
      startMinimized=true
      EOF
            elif ! ${pkgs.gnugrep}/bin/grep -q '^startMinimized=' "$TARGET_FILE"; then
              printf '%s\\n' 'startMinimized=true' >> "$TARGET_FILE"
            else
              ${pkgs.gnused}/bin/sed -i 's/^startMinimized=.*/startMinimized=true/' "$TARGET_FILE"
            fi

            # KTailctl reads this file only at startup.
            systemctl --user try-restart ktailctl.service 2>/dev/null || true
    '';
  };

  # Tailscale online target. NOT added into the boot sequence chain: on
  # networks where Tailscale is blocked/reachable-late/doesn't work, the
  # wait service would otherwise block multi-user/graphical.target for up
  # to 60s and delay niri. Units that do need Tailscale should instead
  # declare `after = ["tailscale-online.target"]` / `wants` it themselves
  # instead of relying on it being part of boot.
  systemd.targets.tailscale-online = {
    description = "Tailscale network online";
    wants = ["tailscaled.service"];
    after = ["tailscaled.service"];
  };

  # Wait for the tailscale0 interface to exist and have an IP
  systemd.services.tailscale-online-wait = {
    description = "Wait for Tailscale Interface";
    before = ["tailscale-online.target"];
    wantedBy = ["tailscale-online.target"];
    after = ["tailscaled.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Checks every second up to 60s for the tailscale0 interface to get an IP address
      ExecStart = "${pkgs.bash}/bin/bash -c 'for i in {1..60}; do if ${pkgs.iproute2}/bin/ip addr show dev tailscale0 2>/dev/null | grep -q \"inet \"; then exit 0; fi; sleep 1; done; echo \"Tailscale timed out\"; exit 1'";
    };
  };
}
