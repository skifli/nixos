{
  inputs,
  lib,
  pkgs,
  userVars,
  ...
}:

{
  home-manager = {
    sharedModules = [ inputs.zen-browser.homeModules.beta ];

    users.${userVars.username} = {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = "zen-beta.desktop";
          "application/x-extension-shtml" = "zen-beta.desktop";
          "application/x-extension-xhtml" = "zen-beta.desktop";
          "application/x-extension-html" = "zen-beta.desktop";
          "application/x-extension-xht" = "zen-beta.desktop";
          "application/x-extension-htm" = "zen-beta.desktop";
          "x-scheme-handler/unknown" = "zen-beta.desktop";
          "x-scheme-handler/chrome" = "zen-beta.desktop";
          "x-scheme-handler/about" = "zen-beta.desktop";
          "x-scheme-handler/https" = "zen-beta.desktop";
          "x-scheme-handler/http" = "zen-beta.desktop";
          "application/xhtml+xml" = "zen-beta.desktop";
          "text/html" = "zen-beta.desktop";
        };
      };

      programs.zen-browser = {
        enable = true;
        policies = import ./zen/policies.nix { inherit lib; };
        languagePacks = [ "en-GB" ];
        profiles = {
          default = {
            id = 0;
            name = "default";
            isDefault = true;
            settings = import ./zen/settings.nix;
            bookmarks = import ./zen/bookmarks.nix;
            search = import ./zen/search.nix { inherit pkgs; };
            /*
              userChrome = builtins.readFile "${arc2}/userChrome.css";
              userContent = builtins.readFile "${arc2}/userContent.css";
            */
            extraConfig = ''
              ${builtins.readFile "${inputs.betterfox}/Fastfox.js"}
              ${builtins.readFile "${inputs.betterfox}/Peskyfox.js"}
              ${builtins.readFile "${inputs.betterfox}/Securefox.js"}
              ${builtins.readFile "${inputs.betterfox}/Smoothfox.js"}
              lockPref("extensions.formautofill.addresses.enabled", false);
              lockPref("extensions.formautofill.creditCards.enabled", false);
              lockPref("dom.security.https_only_mode_pbm", true);
              lockPref("dom.security.https_only_mode_error_page_user_suggestions", true);
              lockPref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");
              lockPref("identity.fxaccounts.enabled", false);
              lockPref("browser.tabs.firefox-view-next", false);
              lockPref("privacy.sanitize.sanitizeOnShutdown", false);
              lockPref("privacy.clearOnShutdown.cache", true);
              lockPref("privacy.clearOnShutdown.cookies", false);
              lockPref("privacy.clearOnShutdown.offlineApps", false);
              lockPref("browser.sessionstore.privacy_level", 0);
              lockPref("floorp.browser.sidebar.enable", false);
              lockPref("geo.enabled", false);
              lockPref("media.navigator.enabled", false);
              lockPref("dom.event.clipboardevents.enabled", false);
              lockPref("dom.event.contextmenu.enabled", false);
              lockPref("dom.battery.enabled", false);
              lockPref("extensions.enabledScopes", 15);
              lockPref("extensions.autoDisableScopes", 0);
              lockPref("browser.newtabpage.activity-stream.floorp.newtab.imagecredit.hide", true);
              lockPref("browser.newtabpage.activity-stream.floorp.newtab.releasenote.hide", true);
              lockPref("browser.search.separatePrivateDefault", true);
            '';
          };
        };
      };
    };
  };
}
