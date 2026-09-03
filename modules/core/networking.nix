{
  config,
  hostVars,
  lib,
  ...
}: let
  wifiSecretKey = "${hostVars.hostname}-wifi.env";
  hasWifiSecret = builtins.hasAttr wifiSecretKey config.age.secrets;
in {
  networking = {
    hostName = hostVars.hostname;

    wireless.iwd.enable = lib.mkDefault false; # iwd toggled per-host (see hosts/*)
    nftables.enable = true; # To use the newer nftables instead

    networkmanager = {
      enable = true;
      wifi.backend = lib.mkDefault "wpa_supplicant";

      # Reduce connect timeout for faster failure recovery
      connectionConfig = {
        "connection.auth-retries" = 2;
      };
      # Use systemd-resolved for better DNS caching
      dns = "systemd-resolved";

      ensureProfiles = lib.mkIf (hasWifiSecret && hostVars.useDeclarativeWifi) {
        environmentFiles = [
          config.age.secrets.${wifiSecretKey}.path
        ];
        profiles = {
          "wifi-1" = {
            connection = {
              id = "$WIFI_SSID";
              type = "wifi";
              autoconnect = true;
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$WIFI_SSID";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$WIFI_PASS";
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "default";
              method = "auto";
            };
            proxy = {};
          };
        };
      };
    };

    # Better DNS resolution with fallbacks
    nameservers = [
      "1.1.1.1" # Cloudflare (fast)
      "9.9.9.9" # Quad9
      "1.0.0.1" # Cloudflare secondary
    ];

    enableIPv6 = true;

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
  };

  services.resolved = {
    enable = true;
    # It auto sets settings.Resolve.DNS to config.networking.nameservers
  };
}
