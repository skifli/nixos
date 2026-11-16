{
  config,
  hostVars,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sernix.xrayClient;

  proxyUser = builtins.head hostVars.enabledUsers;
  overrideFile = "/home/${proxyUser}/.config/xray-proxy/override";

  proxySecretKey = "${hostVars.hostname}-xray-proxy.env";
  proxySecretPath = config.age.secrets.${proxySecretKey}.path;
  hasProxySecret = builtins.hasAttr proxySecretKey config.age.secrets;

  prefixSecretKey = "${hostVars.hostname}-proxy-prefixes.env";
  prefixSecretPath = config.age.secrets.${prefixSecretKey}.path;
  hasPrefixes = builtins.hasAttr prefixSecretKey config.age.secrets;

  # With auto_route, sing-box makes systemd-resolved send all DNS for
  # singtun0 (~.) to 172.19.0.2. Hijack port 53 before the private-IP
  # "direct" rule, otherwise those packets are forwarded to the fake tun
  # address instead of being answered by the DNS module.
  #
  # The "system" TUN stack does not complete TCP handshakes from singtun0
  # on this kernel (SYNs stay in SYN-SENT, sing-box never logs the
  # connection); gvisor with an explicit MTU of 9000 works.
  serverName = if cfg.sni == null then cfg.server else cfg.sni;

  vlessOutbound = {
    type = "vless";
    tag = "proxy";
    # Resolve the endpoint in ExecStartPre, before the TUN changes DNS
    # routing. Keep the hostname separately for TLS SNI and the WS Host.
    server = "__XRAY_SERVER_IP__";
    server_port = cfg.port;
    uuid = "__XRAY_UUID__";
    tls = {
      enabled = true;
      server_name = serverName;
      alpn = [ "http/1.1" ];
      utls = {
        enabled = true;
        fingerprint = "chrome";
      };
    }
    // lib.optionalAttrs cfg.allowInsecure {
      insecure = true;
    };
  }
  // lib.optionalAttrs (cfg.transport == "ws") {
    transport = {
      type = "ws";
      path = cfg.wsPath;
      headers.Host = serverName;
    };
  }
  // lib.optionalAttrs (cfg.transport == "vision") {
    flow = "xtls-rprx-vision";
  };

  configTemplate = pkgs.writeText "xray-proxy.json" (
    builtins.toJSON {
      log = {
        level = "info";
        timestamp = true;
      };
      dns = {
        servers = [
          {
            tag = "remote";
            type = "https";
            server = "1.1.1.1";
            server_port = 443;
            path = "/dns-query";
            detour = "proxy";
          }
          {
            tag = "local";
            type = "local";
          }
        ];
        rules = [
          {
            action = "route";
            server = "local";
            ip_cidr = [
              "100.64.0.0/10"
              "127.0.0.0/8"
              "::1/128"
              "fe80::/10"
            ];
          }
          {
            action = "route";
            server = "remote";
          }
        ];
      };
      inbounds = [
        {
          type = "tun";
          tag = "tun-in";
          interface_name = "singtun0";
          address = [ "172.19.0.1/28" ];
          auto_route = true;
          # Run before Tailscale's marked-socket rules so tailscaled's
          # control-plane and DERP TCP connections enter the proxy TUN.
          # Exclude the tailnet address ranges from this table so peer traffic
          # falls through to Tailscale's own policy-routing table (52).
          iproute2_rule_index = 5000;
          route_exclude_address = [
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];
          strict_route = false;
          stack = "gvisor";
          mtu = 9000;
        }
        {
          type = "mixed";
          tag = "mixed-in";
          listen = "127.0.0.1";
          listen_port = 2080;
        }
      ];
      outbounds = [
        vlessOutbound
        {
          type = "direct";
          tag = "direct";
        }
        {
          type = "block";
          tag = "block";
        }
      ];
      route = {
        auto_detect_interface = true;
        default_domain_resolver = "local";
        rules = [
          {
            action = "hijack-dns";
            port = 53;
          }
          # Keep Tailscale UDP on the underlying network. Proxying it hides
          # native UDP reachability and adds a proxy hop. Include the standalone
          # CLI so `tailscale netcheck` measures this same native UDP path.
          {
            action = "route";
            outbound = "direct";
            network = "udp";
            process_name = [
              "tailscaled"
              "tailscale"
            ];
          }
          {
            action = "route";
            outbound = "direct";
            ip_is_private = true;
          }
          {
            action = "route";
            outbound = "direct";
            ip_cidr = [
              "100.64.0.0/10"
              "224.0.0.0/4"
              "255.255.255.255/32"
              "fc00::/7"
              "fe80::/10"
              "ff00::/8"
            ];
          }
          {
            action = "route";
            outbound = "proxy";
          }
        ];
      };
    }
  );
in
{
  options.sernix.xrayClient = {
    server = lib.mkOption {
      type = lib.types.str;
      default = "xray.warp-racing.com";
      description = "VLESS server hostname.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "VLESS server port.";
    };

    sni = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "TLS server name. Defaults to the server hostname.";
    };

    transport = lib.mkOption {
      type = lib.types.enum [
        "ws"
        "vision"
      ];
      default = "ws";
      description = "VLESS transport: WebSocket (Cloudflare/Tailscale) or XTLS Vision (direct TLS).";
    };

    wsPath = lib.mkOption {
      type = lib.types.str;
      default = "/xray";
      description = "WebSocket path for the ws transport.";
    };

    allowInsecure = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Skip TLS certificate verification (only for direct TLS with a self-signed cert).";
    };
  };

  config = lib.mkMerge [
    {
      # Manual bar overrides should last for this boot only. Clear the
      # persistent marker at boot so SSID-based automatic mode takes over.
      systemd.tmpfiles.rules = lib.optional hasPrefixes "r ${overrideFile} - - - -";
    }
    {
      systemd.services.xray-proxy = lib.mkIf hasProxySecret {
        description = "Xray proxy (sing-box TUN, VLESS/WS)";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        path = with pkgs; [
          sing-box
          coreutils
          getent
          gnused
        ];

        serviceConfig = {
          Type = "simple";
          RuntimeDirectory = "xray-proxy";
          RuntimeDirectoryMode = "0700";
          UMask = "0077";
          ExecStartPre = [
            # Generate the config from the age-decrypted env secret.
            (pkgs.writeShellScript "xray-proxy-gen" ''
              set -euo pipefail
              set -a
              . "${proxySecretPath}"
              set +a

              uuid="''${XRAY_UUID:-}"
              if ! [[ "$uuid" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
                echo "Invalid or missing XRAY_UUID in ${proxySecretPath}" >&2
                exit 1
              fi

              # Resolve before sing-box starts its TUN. Otherwise resolving
              # the VLESS server itself can follow the system DNS route back
              # into this proxy and time out during connection setup.
              server_records="$(getent ahostsv4 ${lib.escapeShellArg cfg.server} || true)"
              server_ip="''${server_records%%[[:space:]]*}"
              if ! [[ "$server_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "Unable to resolve Xray endpoint ${cfg.server} to IPv4 before starting the TUN" >&2
                exit 1
              fi

              umask 077
              ${pkgs.gnused}/bin/sed \
                -e "s/__XRAY_UUID__/$uuid/g" \
                -e "s/__XRAY_SERVER_IP__/$server_ip/g" \
                "${configTemplate}" > "$RUNTIME_DIRECTORY/config.json"
              ${pkgs.sing-box}/bin/sing-box check -c "$RUNTIME_DIRECTORY/config.json"
            '')
          ];
          ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /run/xray-proxy/config.json";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    }
    {
      environment.shellAliases = {
        p-on = "sudo systemctl start xray-proxy.service";
        p-off = "sudo systemctl stop xray-proxy.service";
        p-st = "systemctl is-active xray-proxy.service; systemctl status --no-pager -n 5 xray-proxy.service";
      };
    }
    {
      systemd.services.xray-proxy-ensure = lib.mkIf hasPrefixes {
        description = "Ensure Xray proxy is active on matching wifi networks";
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
          ExecStart = pkgs.writeShellScript "xray-proxy-ensure" ''
            set -euo pipefail

            # Respect a manual override written by the wayle bar "xray-proxy"
            # toggle in the host user's home:
            #   "on"  -> force start, "off" -> force stop, absent -> auto by SSID.
            if [ -f "${overrideFile}" ]; then
              case "$(cat "${overrideFile}")" in
                on)
                  echo "xray-proxy-ensure: manual override=on, starting proxy"
                  systemctl start xray-proxy.service 2>/dev/null || true
                  ;;
                off)
                  echo "xray-proxy-ensure: manual override=off, stopping proxy"
                  systemctl stop xray-proxy.service 2>/dev/null || true
                  ;;
                *)
                  echo "xray-proxy-ensure: manual override='$(cat "${overrideFile}")' unrecognised, ignoring"
                  ;;
              esac
              exit 0
            fi

            mapfile -t PREFIXES < <(
              grep -v '^\s*#' "$PROXY_PREFIXES_FILE" | grep -v '^\s*$' || true
            )

            if [ ''${#PREFIXES[@]} -eq 0 ]; then
              echo "xray-proxy-ensure: no prefixes configured, stopping proxy"
              systemctl stop xray-proxy.service 2>/dev/null || true
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
              echo "xray-proxy-ensure: no active wifi connection after 2m, stopping proxy"
              systemctl stop xray-proxy.service 2>/dev/null || true
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
              echo "xray-proxy-ensure: SSID '$SSID' matches a prefix, ensuring proxy"
              systemctl start xray-proxy.service 2>/dev/null || true
            else
              echo "xray-proxy-ensure: SSID '$SSID' does not match any prefix, stopping proxy"
              systemctl stop xray-proxy.service 2>/dev/null || true
            fi
          '';
        };
      };
    }
    {
      systemd.timers.xray-proxy-ensure = lib.mkIf hasPrefixes {
        description = "Trigger Xray proxy SSID check";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = 0;
          OnUnitActiveSec = 60;
          Unit = "xray-proxy-ensure.service";
        };
      };
    }
    {
      security.sudo.extraRules = lib.mkIf hasProxySecret [
        {
          users = [ proxyUser ];
          commands = [
            {
              command = "/run/current-system/sw/bin/systemctl start xray-proxy.service";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl stop xray-proxy.service";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemctl start xray-proxy-ensure.service";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    }
  ];
}
