{
  config,
  hostVars,
  lib,
  ...
}:
let
  wifiSecretKey = "${hostVars.hostname}-wifi.env";
  hasWifiSecret = builtins.hasAttr wifiSecretKey config.age.secrets;
  normalizeWifi =
    entry:
    if builtins.isString entry then
      { type = entry; privacy = false; }
    else
      entry // { type = entry.type; privacy = entry.privacy or false; };

  wifiTypes = map normalizeWifi (hostVars.declarativeWifi or [ ]);
  wifiCount = builtins.length wifiTypes;

  # Prefer networks in order of the list: wifi-1 is most preferred, then wifi-2, etc.
  priorityFor = i: (wifiCount - i + 1) * 10;

  privacySettings = {
    wifi = {
      cloned-mac-address = "random";
      mac-address-randomization = 1;
    };
    ipv4."dhcp-send-hostname" = false;
    ipv6 = {
      "dhcp-send-hostname" = false;
      "dhcp-duid" = "ll";
      "addr-gen-mode" = "stable-privacy";
      "ip6-privacy" = 2;
    };
  };

  mkPsk =
    i: privacy:
    let
      idx = toString i;
      settings = {
        connection = {
          id = "$WIFI_${idx}_SSID";
          type = "wifi";
          autoconnect = true;
          autoconnect-priority = priorityFor i;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$WIFI_${idx}_SSID";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          pmf = 2;
          psk = "$WIFI_${idx}_PASS";
        };
        ipv4.method = "auto";
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };
    in
    if privacy then lib.recursiveUpdate settings privacySettings else settings;

  mkEap =
    i: privacy:
    let
      idx = toString i;
      settings = {
        connection = {
          id = "$WIFI_${idx}_SSID";
          type = "wifi";
          autoconnect = true;
          autoconnect-priority = priorityFor i;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$WIFI_${idx}_SSID";
        };
        wifi-security = {
          key-mgmt = "wpa-eap";
          auth-alg = "open";
          pmf = 2;
        };
        "802-1x" = {
          eap = "peap;";
          identity = "$WIFI_${idx}_USER";
          password = "$WIFI_${idx}_PASS";
          phase2-auth = "mschapv2";
          system-ca-certs = false;
        };
        ipv4.method = "auto";
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
      };
    in
    if privacy then lib.recursiveUpdate settings privacySettings else settings;

  mkProfile =
    i:
    let
      entry = builtins.elemAt wifiTypes (i - 1);
      value =
        if entry.type == "psk" then (mkPsk i entry.privacy)
        else (mkEap i entry.privacy);
    in
    {
      name = "wifi-${toString i}-${entry.type}";
      inherit value;
    };

  indices = if wifiCount > 0 then lib.range 1 wifiCount else [ ];
  allProfiles = map mkProfile indices;
in
{
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

      ensureProfiles = lib.mkIf (hasWifiSecret && wifiCount > 0) {
        environmentFiles = [
          config.age.secrets.${wifiSecretKey}.path
        ];
        profiles = builtins.listToAttrs allProfiles;
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
