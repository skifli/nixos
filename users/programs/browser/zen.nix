{
  hostVars,
  inputs,
  lib,
  pkgs,
  userVars,
  ...
}: let
  primaryBrowser = builtins.elemAt userVars.programs.browsers 0;
in {
  # Breaks stuff now apparently - https://github.com/0xc000022070/zen-browser-flake#missing-configuration-after-update
  # environment.variables.MOZ_LEGACY_PROFILES = 1; # Workaround for https://github.com/0xc000022070/zen-browser-flake/issues/63;

  home-manager = {
    sharedModules = [inputs.zen-browser.homeModules.beta];

    users.${userVars.username} = {
      home.packages = with pkgs; [speechd];

      home.activation = {
        zenBrowserPrepare =
          inputs.home-manager.lib.hm.dag.entryBefore [
            "zen-sessions-default"
            "zen-keyboard-shortcuts-default"
            "zen-mods-default"
            "zen-sine-mods-default"
          ] ''
            STATE_FILE="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/zen-browser-was-running-before-activation"

            zen_is_running() {
              pgrep -af '(^|/)(zen-beta|zen)([[:space:]]|$)' >/dev/null 2>&1
            }

            prompt_close_zen() {
              local prompt_text=$'Zen Browser is running, and Nix wants to apply profile changes.\n\nClose Zen now and reopen it after activation?\nIf you keep it open, the rebuild will skip the auto-close step.'

              if command -v kdialog >/dev/null 2>&1; then
                kdialog --title="Zen Browser update" --yesno "$prompt_text"
              else
                ${lib.getExe pkgs.zenity} \
                  --question \
                  --title="Zen Browser update" \
                  --width=520 \
                  --text="$prompt_text"
              fi
            }

            rm -f "$STATE_FILE"

            if zen_is_running; then
              touch "$STATE_FILE"

              if [ -n "''${DISPLAY:-}''${WAYLAND_DISPLAY:-}" ]; then
                if ! prompt_close_zen; then
                  rm -f "$STATE_FILE"
                  exit 0
                fi
              fi

              pkill -TERM -f '(^|/)(zen-beta|zen)([[:space:]]|$)' || true

              sleep 3

              zen_is_running && pkill -KILL -f '(^|/)(zen-beta|zen)([[:space:]]|$)' || true
            fi
          '';

        zenBrowserReopen =
          inputs.home-manager.lib.hm.dag.entryAfter [
            "zenBrowserPrepare"
            "zen-sessions-default"
            "zen-keyboard-shortcuts-default"
            "zen-mods-default"
            "zen-sine-mods-default"
          ] ''
            STATE_FILE="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/zen-browser-was-running-before-activation"

            if [ -f "$STATE_FILE" ]; then
              rm -f "$STATE_FILE"

              if [ -n "''${DISPLAY:-}''${WAYLAND_DISPLAY:-}" ]; then
                if command -v zen-beta >/dev/null 2>&1; then
                  nohup zen-beta >/dev/null 2>&1 &
                elif command -v zen >/dev/null 2>&1; then
                  nohup zen >/dev/null 2>&1 &
                fi
              fi
            fi
          '';
      };

      stylix.targets.zen-browser.enable = false;

      programs.zen-browser = {
        enable = true;

        # Native messaging hosts for browser-application communication
        # Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_messaging
        # Option 1: Via Home Manager
        # Source: https://github.com/0xc000022070/zen-browser-flake/blob/main/examples/14-native-messaging.nix
        nativeMessagingHosts = [pkgs.firefoxpwa];

        # Auto sets up mimes etc https://github.com/0xc000022070/zen-browser-flake/blob/42f41abcef13dc81c85407b57aa1fd1bde46e46c/hm-module/default-browser.nix#L33
        setAsDefaultBrowser = primaryBrowser == "zen-beta" || primaryBrowser == "zen";
        enablePrivateDesktopEntry = true;

        policies = import ./zen/policies.nix {inherit hostVars;};
        languagePacks = [hostVars.locale-simple];
        profiles.default = import ./zen/profile-default.nix {inherit hostVars inputs pkgs;};
      };
    };
  };
}
