# Three-layer configuration overview:
#
# 1. policies (top-level, policies.json)
#    DisableAppUpdate, DisablePocket, etc. — enforced, user can't change
#
# 2. policies.Preferences (in policies.json)
#    Locked preference values like browser.startup.homepage — enforced, user can't change
#
# 3. profiles.*.settings (prefs.js)
#    User preferences like zen.* settings — defaults, user can change in browser
#
# Key rules for profiles.*.settings:
# - ALWAYS quote non-Zen keys: "browser.tabs.warnOnClose" = false;
# - Don't use nested notation for browser.*: don't do browser = { tabs.warnOnClose = ... }
# - Zen.* settings work reliably with quoted keys
# - Settings persist to prefs.js; user can override in browser
#
# Troubleshooting settings not persisting: see issue #293
# https://github.com/0xc000022070/zen-browser-flake/issues/293
#
# Source - https://github.com/0xc000022070/zen-browser-flake/blob/main/examples/02b-settings-preferences.nix
{ hostVars, ... }:

let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  # TODO: Set-up and set to the value I want
  # "browser.uiCustomization.state" = builtins.toJSON {};

  # NO LONGER NEEDED WITH https://zen-browser.app/mods/e122b5d9-d385-4bf8-9971-e137809097d0/?page=3 YAY!
  "browser.newtabpage.activity-stream.feeds.system.topsites" = true;
  "browser.newtabpage.activity-stream.feeds.system.topstories" = true;

  "browser.aboutwelcome.enabled" = false;
  "browser.ctrlTab.sortByRecentlyUsed" = true; # Literally so bad without this LOL
  "browser.startup.firstrunSkipsHomepage" = true;
  "browser.startup.homepage_override.mstone" = "ignore";
  "trailhead.firstrun.didSeeAboutWelcome" = true;
  
  # Do not tell what plugins we have enabled: https://mail.mozilla.org/pipermail/firefox-dev/2013-November/001186.html
  "plugins.enumerable_names" = "";
  "plugin.state.flash" = 0;
  "browser.search.update" = false;
  "extensions.ui.sitepermission.hidden" = lock-true;
  "extensions.ui.locale.hidden" = lock-true;
  "extensions.screenshots.disabled" = lock-true;
  "extensions.getAddons.cache.enabled" = lock-false;
  "extensions.getAddons.showPane" = lock-false;
  "extensions.htmlaboutaddons.recommendations.enabled" = lock-false;
  "extensions.extensions.activeThemeID" = "firefox-compact-light@mozilla.org";
  "extensions.update.enabled" = true;
  "extensions.webcompat.enable_picture_in_picture_overrides" = true;
  "extensions.webcompat.enable_shims" = true;
  "extensions.webcompat.perform_injections" = true;
  "extensions.webcompat.perform_ua_overrides" = true;
  "extensions.autoDisableScopes" = { # Stops any potential conflict with Nix or something trying to install extensions
    Value = 0;
    Status = "locked";
  };
  "extensions.enabledScopes" = {
    Value = 15;
    Status = "locked";
  };
  "extensions.allowPrivateBrowsingByDefault" = lock-true;
  "extensions.webextensions.restrictedDomains" = {
    Value = "";
    Status = "locked";
  };

  # Performance settings
  "gfx.webrender.all" = true; # Force enable GPU acceleration
  "media.ffmpeg.vaapi.enabled" = true;
  "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
  "reader.parse-on-load.force-enabled" = true;
  "privacy.webrtc.legacyGlobalIndicator" = false;

  # Remove trackers
  "privacy.purge_trackers.enabled" = lock-true;
  "privacy.trackingprotection.enabled" = false;
  "privacy.trackingprotection.fingerprinting.enabled" = lock-true;
  "privacy.trackingprotection.socialtracking.enabled" = lock-true;
  "privacy.trackingprotection.cryptomining.enabled" = lock-true;
  "privacy.globalprivacycontrol.enabled" = lock-true;
  "privacy.globalprivacycontrol.functionality.enabled" = lock-true;
  "privacy.query_stripping.enabled" = true;
  "privacy.query_stripping.enabled.pbmode" = lock-true;
  "privacy.resistFingerprinting" = false;
  "privacy.donottrackheader.enabled" = lock-true;

  # Block telemetry
  "toolkit.telemetry.enabled" = lock-false;
  "toolkit.telemetry.unified" = lock-false;
  "toolkit.telemetry.server" = "data:,";
  "toolkit.telemetry.archive.enabled" = lock-false;
  "toolkit.telemetry.newProfilePing.enabled" = lock-false;
  "toolkit.telemetry.shutdownPingSender.enabled" = lock-false;
  "toolkit.telemetry.updatePing.enabled" = lock-false;
  "toolkit.telemetry.bhrPing.enabled" = lock-false;
  "toolkit.telemetry.coverage.opt-out" = lock-true;
  "toolkit.telemetry.firstShutdownPing.enabled" = lock-false;
  "browser.newtabpage.activity-stream.telemetry" = lock-false;
  "browser.ping-centre.telemetry" = lock-false;

    # Block more unwanted stuff
  "dom.block_multiple_popups" = lock-true;
  "browser.privatebrowsing.forceMediaMemoryCache" = lock-true;
  "browser.contentblocking.category" = {
    Value = "strict";
    Status = "locked";
  };
  "browser.search.suggest.enabled" = lock-false;
  "browser.search.suggest.enabled.private" = lock-false;
  "privacy.popups.disable_from_plugins" = 3;
  "extensions.pocket.enabled" = lock-false;
  "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
  "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
  "browser.newtabpage.activity-stream.feeds.topsites" = lock-false;
  "browser.newtabpage.activity-stream.showSponsored" = lock-false;
  "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
  "layout.word_select.eat_space_to_next_word" = lock-false;
  "browser.shell.checkDefaultBrowser" = lock-false;
  "signon.rememberSignons" = lock-false;
  "toolkit.coverage.opt-out" = lock-true;
  "toolkit.coverage.endpoint.base" = "";
  "experiments.supported" = lock-false;
  "experiments.enabled" = lock-false;
  "experiments.manifest.uri" = "";
  "datareporting.healthreport.uploadEnabled" = lock-false;
  "datareporting.healthreport.service.enabled" = lock-false;
  "datareporting.policy.dataSubmissionEnabled" = lock-false;
  "breakpad.reportURL" = "";
  "browser.tabs.crashReporting.sendReport" = lock-false;
  "browser.crashReports.unsubmittedCheck.autoSubmit2" = lock-false;
  "browser.formfill.enable" = lock-false;
  "extensions.formautofill.addresses.enabled" = lock-false;
  "extensions.formautofill.available" = "off";
  "extensions.formautofill.creditCards.available" = lock-false;
  "extensions.formautofill.creditCards.enabled" = lock-false;
  "extensions.formautofill.heuristics.enabled" = lock-false;
  "app.normandy.enabled" = lock-false;
  "app.normandy.api_url" = "";
  "dom.webnotifications.enabled" = lock-false;
  "dom.webnotifications.serviceworker.enabled" = lock-false;

  # Permissions
  # 0=always ask (default), 1=allow, 2=block
  "permissions.default.geo" = 0;
  "permissions.default.camera" = 0;
  "permissions.default.microphone" = 0;
  "permissions.default.desktop-notification" = 0;
  "permissions.default.xr" = 0; # Virtual Reality

  # General settings
  "intl.locale.requested" = hostVars.locale-simple; # Use simple locale for browser UI
  "browser.aboutConfig.showWarning" = lock-false;
  "browser.aboutwelcome.enabled" = lock-false;
  "browser.tabs.firefox-view" = lock-false;
  "browser.startup.homepage_override.mstone" = "ignore";
  "trailhead.firstrun.didSeeAboutWelcome" = lock-true; # Disable welcome splash
  "browser.newtab.url" = "about:blank";
  "browser.newtabpage.activity-stream.enabled" = lock-false;
  "browser.newtabpage.enhanced" = lock-false;
  "browser.newtabpage.introShown" = lock-true;
  "browser.newtabpage.pinned" = false;
  "browser.bookmarks.defaultLocation" = "toolbar";
  "browser.startup.page" = 3;
  "app.shield.optoutstudies.enabled" = lock-false;
  "dom.security.https_only_mode" = lock-true;
  "dom.security.https_only_mode_ever_enabled" = lock-true;
  "identity.fxaccounts.enabled" = lock-false;
  "app.update.auto" = false;
  "browser.startup.homepage" = "";
  "browser.bookmarks.restore_default_bookmarks" = false;
  "browser.ctrlTab.recentlyUsedOrder" = true;
  "browser.ctrlTab.previews" = true;
  "browser.ctrlTab.sortByRecentlyUsed" = true;
  "browser.discovery.enabled" = false;
  "browser.laterrun.enabled" = false;
  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
  "browser.newtabpage.activity-stream.feeds.snippets" = false;
  "browser.newtabpage.activity-stream.feeds.system.topsites" = true;
  "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
  "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
  "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
  "browser.protections_panel.infoMessage.seen" = lock-true;
  "browser.ssb.enabled" = true;
  "browser.tabs.allow_transparent_browser" = false;
  "browser.toolbars.bookmarks.visibility" = "never"; # always, never, newtab
  # "browser.urlbar.placeholderName" = "Google";
  "browser.urlbar.suggest.history" = false;
  "browser.urlbar.suggest.topsites" = lock-false;
  "browser.urlbar.suggest.openpage" = lock-false;
  "browser.urlbar.suggest.recentsearches" = lock-false;
  "datareporting.policy.dataSubmissionEnable" = false;
  "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;

  "layout.css.devPixelsPerPx" = -1;
  # "zen.theme.accent-color" = "#ffb787";
  "zen.theme.acrylic-elements" = false;
  "zen.theme.border-radius" = 8;
  "zen.theme.content-element-separation" = 0;
  "zen.theme.dark-mode-bias" = 0.3;
  # "zen.theme.disable-lightweight" = true; Depracated https://github.com/zen-browser/desktop/issues/9522#issuecomment-3089206722
  "zen.theme.essentials-favicon-bg" = true;
  "zen.theme.gradient" = true;
  "zen.theme.gradient.show-custom-colors" = false;
  "zen.theme.hide-tab-throbber" = true;
  "zen.theme.show-custom-colors" = true;
  "zen.theme.styled-status-panel" = false;
  "zen.theme.use-sysyem-colors" = false;
  "zen.theme.use-system-colors" = false;

  "zen.urlbar.behavior" = "float";
  "zen.urlbar.replace-newtab" = true;
  
  "zen.view.compact.enable-at-startup" = true;
  "zen.view.compact.hide-tabbar" = true;
  "zen.view.compact.hide-toolbar" = true;
  "zen.view.experimental-no-window-controls" = true;
  "zen.view.sidebar-expanded" = true;
  "zen.view.use-single-toolbar" = true;

  "zen.watermark.enabled" = false;
  "zen.welcome-screen.seen" = lock-true;
  "zen.widget.linux.transparency" = false; # Disable transparent sidebar
  "zen.workspaces.continue-where-left-off" = true;
}
