{
  config,
  hostVars,
  lib,
  pkgs,
  ...
}:
let
  proxyUser = builtins.head hostVars.enabledUsers;
  overrideFile = "/home/${proxyUser}/.config/oracle-proxy/override";

  proxySecretKey = "${hostVars.hostname}-oracle-proxy.env";
  proxySecretPath = config.age.secrets.${proxySecretKey}.path;
  hasProxySecret = builtins.hasAttr proxySecretKey config.age.secrets;

  prefixSecretKey = "${hostVars.hostname}-warp-prefixes.env";
  prefixSecretPath = config.age.secrets.${prefixSecretKey}.path;
  hasPrefixes = builtins.hasAttr prefixSecretKey config.age.secrets;

  configTemplate = pkgs.writeText "oracle-proxy.json" ''
    {
      "log": {
        "level": "info",
        "timestamp": true
      },
      "dns": {
        "servers": [
          {
            "tag": "remote",
            "type": "https",
            "server": "1.1.1.1",
            "server_port": 443,
            "path": "/dns-query",
            "detour": "proxy"
          },
          {
            "tag": "local",
            "type": "local"
          }
        ],
        "rules": [
          {
            "action": "route",
            "server": "local",
            "ip_cidr": [
              "100.64.0.0/10",
              "127.0.0.0/8",
              "::1/128",
              "fe80::/10"
            ]
          },
          {
            "action": "route",
            "server": "remote"
          }
        ]
      },
      "inbounds": [
        {
          "type": "tun",
          "tag": "tun-in",
          "interface_name": "singtun0",
          "address": [
            "172.19.0.1/28"
          ],
          "auto_route": true,
          "strict_route": false,
          "stack": "system"
        },
        {
          "type": "mixed",
          "tag": "mixed-in",
          "listen": "127.0.0.1",
          "listen_port": 2080
        }
      ],
      "outbounds": [
        {
          "type": "shadowsocks",
          "tag": "proxy",
          "server": "$PROXY_SERVER",
          "server_port": $PROXY_PORT,
          "method": "$PROXY_METHOD",
          "password": "$PROXY_PASSWORD"
        },
        {
          "type": "direct",
          "tag": "direct"
        },
        {
          "type": "block",
          "tag": "block"
        }
      ],
      "route": {
        "rules": [
          {
            "action": "route",
            "outbound": "direct",
            "ip_is_private": true
          },
          {
            "action": "route",
            "outbound": "direct",
            "ip_cidr": [
              "100.64.0.0/10",
              "224.0.0.0/4",
              "255.255.255.255/32",
              "fc00::/7",
              "fe80::/10",
              "ff00::/8"
            ]
          },
          {
            "action": "route",
            "outbound": "proxy"
          }
        ]
      }
    }
  '';
in
{
  systemd.services.oracle-proxy = lib.mkIf hasProxySecret {
    description = "Oracle VPS proxy (sing-box TUN)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [
      sing-box
      gettext
      coreutils
    ];

    serviceConfig = {
      Type = "simple";
      RuntimeDirectory = "oracle-proxy";
      RuntimeDirectoryMode = "0750";
      ExecStartPre = [
        # Generate the config from the age-decrypted env secret.
        (pkgs.writeShellScript "oracle-proxy-gen" ''
          set -euo pipefail
          set -a
          . "${proxySecretPath}"
          set +a
          ${pkgs.gettext}/bin/envsubst < "${configTemplate}" > /run/oracle-proxy/config.json
          ${pkgs.sing-box}/bin/sing-box check -c /run/oracle-proxy/config.json
        '')
      ];
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /run/oracle-proxy/config.json";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  environment.shellAliases = {
    p-on = "sudo systemctl start oracle-proxy.service";
    p-off = "sudo systemctl stop oracle-proxy.service";
    p-st = "systemctl is-active oracle-proxy.service; systemctl status --no-pager -n 5 oracle-proxy.service";
  };

  systemd.services.oracle-proxy-ensure = lib.mkIf hasPrefixes {
    description = "Ensure Oracle proxy is active on matching wifi networks";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      networkmanager
      gnugrep
      coreutils
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      TimeoutStartSec = 150;
      Environment = "PROXY_PREFIXES_FILE=${prefixSecretPath}";
      ExecStart = pkgs.writeShellScript "oracle-proxy-ensure" ''
        set -euo pipefail

        # Respect a manual override written by the wayle bar "oracle-proxy"
        # toggle in the host user's home:
        #   "on"  -> force start, "off" -> force stop, absent -> auto by SSID.
        if [ -f "${overrideFile}" ]; then
          case "$(cat "${overrideFile}")" in
            on)
              echo "oracle-proxy-ensure: manual override=on, starting proxy"
              systemctl start oracle-proxy.service 2>/dev/null || true
              ;;
            off)
              echo "oracle-proxy-ensure: manual override=off, stopping proxy"
              systemctl stop oracle-proxy.service 2>/dev/null || true
              ;;
            *)
              echo "oracle-proxy-ensure: manual override='$(cat "${overrideFile}")' unrecognised, ignoring"
              ;;
          esac
          exit 0
        fi

        mapfile -t PREFIXES < <(
          grep -v '^\s*#' "$PROXY_PREFIXES_FILE" | grep -v '^\s*$' || true
        )

        if [ ''${#PREFIXES[@]} -eq 0 ]; then
          echo "oracle-proxy-ensure: no prefixes configured, stopping proxy"
          systemctl stop oracle-proxy.service 2>/dev/null || true
          exit 0
        fi

        # Wait for a wifi connection to appear - NetworkManager may not have
        # connected yet (optimiseBoot disables NetworkManager-wait-online).
        SSID=""
        for i in {1..120}; do
          if SSID="$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep ':802-11-wireless' | cut -d: -f1 | tail -1 || true)"; [ -n "$SSID" ]; then
            break
          fi
          sleep 1
        done

        if [ -z "$SSID" ]; then
          echo "oracle-proxy-ensure: no active wifi connection after 2m, stopping proxy"
          systemctl stop oracle-proxy.service 2>/dev/null || true
          exit 0
        fi

        MATCHED=false
        for prefix in "''${PREFIXES[@]}"; do
          prefix="''${prefix%$'\n'}"
          prefix="''${prefix%"''${prefix##*[![:space:]]}"}"
          if [[ "$SSID" == "$prefix"* ]]; then
            MATCHED=true
            break
          fi
        done

        if [ "$MATCHED" = true ]; then
          echo "oracle-proxy-ensure: SSID '$SSID' matches a prefix, ensuring proxy"
          systemctl start oracle-proxy.service 2>/dev/null || true
        else
          echo "oracle-proxy-ensure: SSID '$SSID' does not match any prefix, stopping proxy"
          systemctl stop oracle-proxy.service 2>/dev/null || true
        fi
      '';
    };
  };

  systemd.timers.oracle-proxy-ensure = lib.mkIf hasPrefixes {
    description = "Trigger Oracle proxy SSID check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = 0;
      OnUnitActiveSec = 60;
      Unit = "oracle-proxy-ensure.service";
    };
  };

  security.sudo.extraRules = lib.mkIf hasProxySecret [
    {
      users = [ proxyUser ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start oracle-proxy.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop oracle-proxy.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl start oracle-proxy-ensure.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
