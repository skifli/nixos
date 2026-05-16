{
  pkgs,
  userVars,
  ...
}: let
  awWatcherUtilizationSrc = pkgs.fetchFromGitHub {
    owner = "Alwinator";
    repo = "aw-watcher-utilization";
    rev = "d0d701b";
    sha256 = "sha256-8bKMCg6I7+0nOrdOplX4VT417Lti+3PHIn3x8Ik24BU=";
  };

  awWatcherInputSrc = pkgs.fetchFromGitHub {
    owner = "skifli";
    repo = "aw-watcher-input";
    rev = "c41b75e";
    sha256 = "sha256-CsCX/9828JF6g5W1Pil+TeMfFcWBZxOzzxiqPS7WhxI=";
  };

  awNotifyRs = pkgs.rustPlatform.buildRustPackage {
    pname = "aw-notify-rs";
    version = "0.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "0xbrayo";
      repo = "aw-notify-rs";
      rev = "9e41fdb";
      sha256 = "sha256-beLuNvgRY1D8/m0xXKLgKOZYNuH/zSED/AskvohlUjM=";
    };

    cargoHash = "sha256-5GVyQg1+xSaSkYNPFTSyagc4/vSWVgFU0p4XV5RAxHw=";

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      openssl
    ];
  };

  pyEnv = pkgs.python313.withPackages (
    ps:
      with ps; [
        aw-client
        aw-core
        psutil

        (ps.buildPythonPackage rec {
          pname = "aw-watcher-netstatus";
          version = "1.0.1";

          src = ps.fetchPypi {
            pname = "aw_watcher_netstatus";
            inherit version;
            sha256 = "sha256-3STAWussghCzqyR9OCYZf8oNi113QCerQJq3GZOwBoc=";
          };

          pyproject = true;

          build-system = with ps; [
            poetry-core
          ];

          propagatedBuildInputs = with ps; [
            aw-client
            aw-core
          ];
        })
      ]
  );
in {
  environment.systemPackages = with pkgs; [
    evtest
    libinput
  ];

  users.users.${userVars.username} = {
    extraGroups = [
      "input"
    ];
  };

  home-manager.users.${userVars.username} = {
    xdg.configFile."activitywatch/aw-notify/config.toml".text = ''
      hourly_checkins = true
      new_day_greetings = true
      server_monitoring = true

      [[alerts]]
      category = "Programming"
      label = "💻 Programming"
      thresholds_minutes = [30, 60, 120, 180, 240]
      positive = true

      [[alerts]]
      category = "Revision"
      label = "📘 Revision"
      thresholds_minutes = [30, 60, 90, 120]
      positive = true

      [[alerts]]
      category = "Work"
      label = "🧠 Work"
      thresholds_minutes = [60, 120, 180, 240]
      positive = true

      [[alerts]]
      category = "Anki"
      label = "🧠 Anki"
      thresholds_minutes = [15, 30, 60]
      positive = true

      [[alerts]]
      category = "Social Media"
      label = "📱 Social Media"
      thresholds_minutes = [15, 30]
      positive = false

      [[alerts]]
      category = "Platforms"
      label = "📉 Reddit / Instagram"
      thresholds_minutes = [15, 30]
      positive = false

      [[alerts]]
      category = "Chats"
      label = "💬 Discord"
      thresholds_minutes = [20, 40]
      positive = false

      [[alerts]]
      category = "Long Format"
      label = "📺 YouTube"
      thresholds_minutes = [20, 45, 90]
      positive = false

      [[alerts]]
      category = "Games"
      label = "🎮 Games"
      thresholds_minutes = [30, 60, 120]
      positive = false

      [[alerts]]
      category = "All"
      label = "⏱️ Total Activity"
      thresholds_minutes = [360, 480]
      positive = false
    '';

    home.packages = with pkgs; [
      awNotifyRs
      awatcher
      aw-qt
    ];

    systemd = {
      user.services = {
        "awatcher" = {
          Unit = {
            Description = "ActivityWatch unified watcher (awatcher)";
            After = ["graphical-session.target"];
          };

          Service = {
            Type = "simple";
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 60"; # Try stop lagging
            ExecStart = "${pkgs.awatcher}/bin/awatcher";
            Restart = "always";
            RestartSec = 3;
          };

          Install = {WantedBy = ["default.target"];};
        };

        "aw-notify" = {
          Unit = {
            Description = "ActivityWatch Notify (Rust)";
            After = ["graphical-session.target"];
          };

          Service = {
            Type = "simple";
            ExecStart = "${awNotifyRs}/bin/aw-notify start";
            Restart = "always";
            RestartSec = 3;
          };

          Install = {WantedBy = ["default.target"];};
        };

        "aw-watcher-input" = {
          Unit = {
            Description = "ActivityWatch Input Watcher";
            After = ["graphical-session.target"];
          };

          Service = {
            Type = "simple";
            WorkingDirectory = "${awWatcherInputSrc}/src";

            ExecStart = ''
              ${pyEnv}/bin/python -c "from aw_watcher_input.main import main; main()"
            '';

            Restart = "always";
            RestartSec = 3;
            Environment = [
              "PATH=${
                pkgs.lib.makeBinPath [pkgs.poetry pkgs.libinput pkgs.evtest]
              }"
            ];
          };

          Install = {WantedBy = ["default.target"];};
        };

        "aw-watcher-netstatus" = {
          Unit = {
            Description = "ActivityWatch Netstatus Watcher";
            After = ["graphical-session.target"];
          };

          Service = {
            Type = "simple";
            ExecStart = "${pyEnv}/bin/aw-watcher-netstatus";
            Restart = "always";
            RestartSec = 3;
          };

          Install = {WantedBy = ["default.target"];};
        };

        "aw-watcher-utilization" = {
          Unit = {
            Description = "ActivityWatch Utilization Watcher";
            After = ["graphical-session.target"];
          };

          Service = {
            Type = "simple";

            ExecStart = let
              script = pkgs.writeShellScript "aw-utilization" ''
                              exec ${pyEnv}/bin/python - <<'EOF'
                import sys
                sys.path.insert(0, "${awWatcherUtilizationSrc}")

                from aw_watcher_utilization.watcher import UtilizationWatcher

                UtilizationWatcher().run()
                EOF
              '';
            in "${script}";

            Restart = "always";
            RestartSec = 3;
          };

          Install = {WantedBy = ["default.target"];};
        };
      };
    };
  };

  systemd.services.pifi-proxy = {
    description = "Port forward 5600 to pifi via Tailscale";
    after = [
      "network.target"
      "tailscaled.service"
    ];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:5600,fork,reuseaddr,bind=127.0.0.1 TCP:pifi:5600";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
