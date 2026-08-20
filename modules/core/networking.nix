{
  config,
  hostVars,
  lib,
  pkgs,
  ...
}: let
  wifiSecretKey = "${hostVars.hostname}-wifi.env";
  hasWifiSecret = builtins.hasAttr wifiSecretKey config.age.secrets;
in {
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

  systemd.services.iwd-wifi-provision = lib.mkIf hasWifiSecret {
    description = "Provision iwd Wi-Fi credentials";
    wantedBy = ["iwd.service"];
    before = ["iwd.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "provision-iwd-wifi" ''
        set -eu
        source "${config.age.secrets.${wifiSecretKey}.path}"

        mkdir -p /var/lib/iwd
        chmod 700 /var/lib/iwd

        TARGET="/var/lib/iwd/''${WIFI_SSID}.psk"

        if [ ! -f "$TARGET" ] || ! grep -q "Passphrase=''${WIFI_PASS}" "$TARGET"; then
          printf '[Security]\nPassphrase=%s\n' "$WIFI_PASS" > "$TARGET"
          chmod 600 "$TARGET"
        fi
      '';
    };
  };
}
