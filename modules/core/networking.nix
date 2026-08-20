{hostVars, ...}: {
  networking = {
    hostName = hostVars.hostname;

    wireless = {
      enable = false;
      iwd.enable = true; # Use iwd not wpa_supplicant
    };

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";

      # Reduce connect timeout for faster failure recovery
      connectionConfig = {
        "connection.auth-retries" = 2;
      };
      # Use systemd-resolved for better DNS caching
      dns = "systemd-resolved";
    };

    # Better DNS resolution with fallbacks (reduces startup delays)
    nameservers = [
      "1.1.1.1" # Cloudflare (fast)
      "9.9.9.9" # Quad9
      "1.0.0.1" # Cloudflare secondary
    ];

    enableIPv6 = true;

    /*
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH (Secure Shell) - remote access
        80 # HTTP - web traffic
        443 # HTTPS - encrypted web traffic
        0 # Custom application port
      ];
      allowedUDPPorts = [
        0 # Custom application port
      ];
    };
    */
  };

  services.resolved = {
    enable = true;
    # It auto sets settings.Resolve.DNS to config.networking.nameservers
  };
}
