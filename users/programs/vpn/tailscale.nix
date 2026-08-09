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

  # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # 3. Optimization: Prevent systemd from waiting for network online
  # (Optional but recommended for faster boot with VPNs)
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  home-manager.users.${userVars.username} = {
    home.activation.setKTailctlConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Make sure that the target dir exists
      mkdir -p "$HOME/.config"

      # Create or overwrite the writeable configuration file
      cat << 'EOF' > "$HOME/.config/KTailctlrc"
  [Interface]
  peerFilter=
  startMinimized=true
  EOF
    '';
  };
}
