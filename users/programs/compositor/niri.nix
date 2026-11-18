{
  inputs,
  lib,
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}@attrs:
let
  default = import ./niri/default.nix attrs;
  safeeyesApp = lib.findFirst (app: app ? breakWindowTitlePrefix) {
    appId = "";
    breakWindowTitlePrefix = "";
  } (userVars.protectedCloseApps or [ ]);
  nirius =
    if safeeyesApp.appId != "" then
      pkgsUnstable.nirius.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./niri/patches/nirius-set-follow-mode.patch ];
      })
    else
      pkgsUnstable.nirius;
  safeeyesFollowWatcher = pkgs.writeShellScript "safeeyes-follow-mode" ''
    set -euo pipefail

    declare -A followed_windows=()

    follow_safeeyes_window() {
      local id="$1"
      [[ -n "$id" ]] || return 0
      [[ -v "followed_windows[$id]" ]] && return 0

      for attempt in {1..5}; do
        if ${nirius}/bin/nirius set-follow-mode \
          --id "$id" --policy if-invisible >/dev/null; then
          followed_windows[$id]=1
          echo "Enabled if-invisible follow mode for SafeEyes window $id"
          return 0
        fi
        sleep 0.1
      done
      echo "Could not enable follow mode for SafeEyes window $id yet; a later window event will retry" >&2
    }

    # Catch break windows that were already open if the watcher starts late.
    while IFS= read -r id; do
      follow_safeeyes_window "$id"
    done < <(
      ${pkgs.niri}/bin/niri msg -j windows | ${pkgs.jq}/bin/jq -r \
        --arg app ${lib.escapeShellArg safeeyesApp.appId} \
        --arg prefix ${lib.escapeShellArg safeeyesApp.breakWindowTitlePrefix} \
        '.[] | select(.app_id == $app and (.title | startswith($prefix))) | .id'
    )

    while IFS= read -r event; do
      closed_id=$(${pkgs.jq}/bin/jq -r '.WindowClosed.id // empty' <<< "$event")
      if [[ -n "$closed_id" ]]; then
        unset "followed_windows[$closed_id]"
      fi

      id=$(${pkgs.jq}/bin/jq -r '
        .WindowOpenedOrChanged.window as $window
        | select($window != null and $window.app_id == $app and (($window.title // "") | startswith($prefix)))
        | $window.id
      ' --arg app ${lib.escapeShellArg safeeyesApp.appId} \
        --arg prefix ${lib.escapeShellArg safeeyesApp.breakWindowTitlePrefix} <<< "$event")
      follow_safeeyes_window "$id"
    done < <(${pkgs.niri}/bin/niri msg -j event-stream)
  '';
in
{
  imports = [
    inputs.niri-nix.nixosModules.default
  ];

  # Home-manager level configuration
  home-manager = {
    users.${userVars.username} = {
      imports = [
        inputs.niri-nix.homeModules.default
      ];

      # Import the default configuration from the sub-folder
      wayland.windowManager.niri = default;

      # Environment variables
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_DESKTOP = "niri";
      };

      systemd.user.services.niriusd = {
        Unit = {
          Description = "nirius daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${nirius}/bin/niriusd";
          Restart = "on-failure";
          RestartSec = "2s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      systemd.user.services.safeeyes-follow-mode = lib.mkIf (safeeyesApp.appId != "") {
        Unit = {
          Description = "Keep SafeEyes break windows visible with Nirius follow mode";
          PartOf = [ "graphical-session.target" ];
          After = [
            "graphical-session.target"
            "niriusd.service"
          ];
        };
        Service = {
          Type = "simple";
          ExecStart = safeeyesFollowWatcher;
          Restart = "always";
          RestartSec = "2s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  /*
    # Used to be in home above only, here as well just in case.
    # Edit: removed because actually uwsm should handle these
    # and otherwise these are set e.g., even when in a TTY which
    # is not what we want.

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
    };
  */

  # NixOS-level configuration
  environment.systemPackages = [
    pkgs.niri
    pkgs.bc # Used for some scripts
    pkgs.jq # Used for some scripts
    pkgs.libnotify # Used for sending notifications to the notification daemon

    nirius # Nirius, locally patched for SafeEyes only on ami@lyra
  ];

  programs = {
    dconf.enable = true; # Niri nixOS module enables this by default but anyway

    # Niri NixOS module
    niri = {
      enable = true;

      useNautilus = false; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-usenautilus

      # Below is managed below manually
      withUWSM = false; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-withuwsm

      # Below is managed manually elsewhere and has custom portal setup + below last line for configPackages
      withXDG = false; # https://codeberg.org/bananad3v/niri-nix/src/branch/main/nixos-options.md#programs-niri-withxdg
    };

    uwsm = {
      enable = true;

      waylandCompositors = {
        niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          binPath = "${pkgs.niri}/bin/niri-session";
        };
      };
    };
  };

  xdg.portal.configPackages = [ pkgs.niri ];
}
