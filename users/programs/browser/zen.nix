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

    users.${userVars.username} = {lib, ...}: {
      # Fix for https://github.com/zen-browser/desktop/issues/7177
      home.activation.fixBase16KvantumBlur = lib.hm.dag.entryAfter ["writeBoundary"] ''
        TARGET_FILE="$HOME/.config/Kvantum/Base16Kvantum/Base16Kvantum.kvconfig"

        if [ -f "$TARGET_FILE" ]; then
          # Force disable blur, transparency, and background opacity layers
          sed -i 's/^popup_blurring.*/popup_blurring=false/' "$TARGET_FILE"
          sed -i 's/^reduce_window_opacity.*/reduce_window_opacity=0/' "$TARGET_FILE"
          sed -i 's/^blur_konsole.*/blur_konsole=false/' "$TARGET_FILE"
          sed -i 's/^blur_translucent.*/blur_translucent=false/' "$TARGET_FILE"
        fi
      '';

      xdg.configFile."Kvantum/Base16Kvantum/Base16Kvantum.kvconfig".force = true;

      home.packages = with pkgs; [kdePackages.kdialog speechd];

      stylix.targets.zen-browser.enable = false;

      programs.zen-browser = {
        enable = true;

        # Set environment variables for the Zen Browser launcher (Linux only).
        # Useful for theming/rendering workarounds, e.g. forcing a readable GTK theme
        # under Wayland. See https://github.com/0xc000022070/zen-browser-flake/issues/290
        env = {};

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
