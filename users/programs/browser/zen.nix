{
  hostVars,
  inputs,
  pkgs,
  userVars,
  ...
}: {
  # Breaks stuff now apparently
  # environment.variables.MOZ_LEGACY_PROFILES = 1; # Workaround for https://github.com/0xc000022070/zen-browser-flake/issues/63;

  home-manager = {
    sharedModules = [inputs.zen-browser.homeModules.beta];

    users.${userVars.username} = {
      home.packages = with pkgs; [speechd];

      stylix.targets.zen-browser.enable = false;

      programs.zen-browser = {
        enable = true;

        # Native messaging hosts for browser-application communication
        # Reference: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Native_messaging
        # Option 1: Via Home Manager
        # Source: https://github.com/0xc000022070/zen-browser-flake/blob/main/examples/14-native-messaging.nix
        nativeMessagingHosts = [pkgs.firefoxpwa];

        setAsDefaultBrowser = true;
        enablePrivateDesktopEntry = true;

        policies = import ./zen/policies.nix {inherit hostVars;};
        languagePacks = [hostVars.locale-simple];
        profiles.default = import ./zen/profile-default.nix {inherit hostVars inputs pkgs;};
      };
    };
  };
}
