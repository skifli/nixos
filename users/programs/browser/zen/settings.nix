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
{hostVars, ...}: {
  /**
   *************************************************************************
  * Locale                                                                   *
  **************************************************************************
  */
  "intl.locale.requested" = hostVars.locale-simple; # Browser UI language

  /**
   *************************************************************************
  * Startup, onboarding, "default browser" nags                              *
  **************************************************************************
  */
  "browser.startup.page" = 3; # Restore previous session
  "browser.startup.homepage" = "";
  "browser.startup.firstrunSkipsHomepage" = true;
  "browser.startup.homepage_override.mstone" = "ignore";

  "browser.aboutConfig.showWarning" = false;
  "browser.aboutwelcome.enabled" = false;
  "trailhead.firstrun.didSeeAboutWelcome" = true;

  "browser.shell.checkDefaultBrowser" = false;
  "browser.tabs.firefox-view" = false;

  /**
   *************************************************************************
  * New tab / Activity Stream                                                *
  **************************************************************************
  */
  "browser.newtab.url" = "about:blank";
  "browser.newtabpage.activity-stream.enabled" = false;
  "browser.newtabpage.enhanced" = false;
  "browser.newtabpage.introShown" = true;
  "browser.newtabpage.pinned" = false;

  # If Activity Stream is enabled again, these keep it quiet by default.
  "browser.topsites.contile.enabled" = false;
  "browser.newtabpage.activity-stream.feeds.snippets" = false;
  "browser.newtabpage.activity-stream.feeds.topsites" = false;
  "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
  "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
  "browser.newtabpage.activity-stream.showSponsored" = false;
  "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
  "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
  "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";

  /**
   *************************************************************************
  * UI / tabs / URL bar                                                      *
  **************************************************************************
  */
  "browser.ctrlTab.recentlyUsedOrder" = true;
  "browser.ctrlTab.previews" = true;
  "browser.ctrlTab.sortByRecentlyUsed" = true;

  "browser.toolbars.bookmarks.visibility" = "never"; # always|never|newtab
  "browser.bookmarks.defaultLocation" = "toolbar";
  "browser.bookmarks.restore_default_bookmarks" = false;

  "browser.urlbar.suggest.history" = false;
  "browser.urlbar.suggest.openpage" = false;
  "browser.urlbar.suggest.recentsearches" = false;
  "browser.urlbar.suggest.topsites" = false;

  /**
   *************************************************************************
  * Search, recommendations, discovery                                       *
  **************************************************************************
  */
  "browser.search.update" = false;
  "browser.search.suggest.enabled" = false;
  "browser.search.suggest.enabled.private" = false;
  "browser.discovery.enabled" = false;

  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
  "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

  /**
   *************************************************************************
  * Extensions                                                                *
  **************************************************************************
  */
  "extensions.update.enabled" = true;
  "extensions.extensions.activeThemeID" = "firefox-compact-light@mozilla.org";

  "extensions.screenshots.disabled" = true;
  "extensions.pocket.enabled" = false;

  "extensions.getAddons.cache.enabled" = false;
  "extensions.getAddons.showPane" = false;
  "extensions.htmlaboutaddons.recommendations.enabled" = false;

  "extensions.ui.sitepermission.hidden" = true;
  "extensions.ui.locale.hidden" = true;
  "extensions.allowPrivateBrowsingByDefault" = true;

  # Stops any potential conflict with Nix/Home Manager installing extensions.
  "extensions.autoDisableScopes" = 0;
  "extensions.enabledScopes" = 15;

  "extensions.formautofill.available" = "off";
  "extensions.formautofill.addresses.enabled" = false;
  "extensions.formautofill.creditCards.available" = false;
  "extensions.formautofill.creditCards.enabled" = false;
  "extensions.formautofill.heuristics.enabled" = false;

  "extensions.webextensions.restrictedDomains" = "";

  # WebCompat (usually safe to keep enabled)
  "extensions.webcompat.enable_picture_in_picture_overrides" = true;
  "extensions.webcompat.enable_shims" = true;
  "extensions.webcompat.perform_injections" = true;
  "extensions.webcompat.perform_ua_overrides" = true;

  /**
   *************************************************************************
  * Privacy & security                                                       *
  **************************************************************************
  */
  # Do not reveal enabled plugins:
  # https://mail.mozilla.org/pipermail/firefox-dev/2013-November/001186.html
  "plugins.enumerable_names" = "";
  "plugin.state.flash" = 0;

  "dom.security.https_only_mode" = true;
  "dom.security.https_only_mode_ever_enabled" = true;
  "network.socket.ip_addr_any.disabled" = true; # Disallow binding to 0.0.0.0

  "privacy.globalprivacycontrol.enabled" = true;
  "privacy.globalprivacycontrol.functionality.enabled" = true;
  "privacy.query_stripping.enabled" = true;
  "privacy.query_stripping.enabled.pbmode" = true;
  "privacy.donottrackheader.enabled" = true;

  "privacy.purge_trackers.enabled" = true;
  "privacy.trackingprotection.enabled" = true;
  "privacy.trackingprotection.fingerprinting.enabled" = true;
  "privacy.trackingprotection.socialtracking.enabled" = true;
  "privacy.trackingprotection.cryptomining.enabled" = true;

  "privacy.resistFingerprinting" = false;
  "privacy.resistFingerprinting.block_mozAddonManager" = true;

  # Popups
  "dom.block_multiple_popups" = true;
  "privacy.popups.disable_from_plugins" = 3;

  # Clear on shutdown (these are defaults; enable in UI if desired)
  "privacy.sanitize.sanitizeOnShutdown" = true;
  "privacy.clearOnShutdown.cache" = true;
  "privacy.clearOnShutdown.cookies" = false;
  "privacy.clearOnShutdown.downloads" = false;
  "privacy.clearOnShutdown.formdata" = true;
  "privacy.clearOnShutdown.history" = false;
  "privacy.clearOnShutdown.offlineApps" = false;
  "privacy.clearOnShutdown.sessions" = false;
  "privacy.clearOnShutdown.siteSettings" = false;

  # Login / autofill
  "signon.rememberSignons" = false;
  "browser.formfill.enable" = false;

  /**
   *************************************************************************
  * Telemetry, studies, crash reporting                                      *
  **************************************************************************
  */
  "app.shield.optoutstudies.enabled" = false;
  "experiments.supported" = false;
  "experiments.enabled" = false;
  "experiments.manifest.uri" = "";

  "app.normandy.enabled" = false;
  "app.normandy.api_url" = "";

  "datareporting.healthreport.uploadEnabled" = false;
  "datareporting.healthreport.service.enabled" = false;
  "datareporting.policy.dataSubmissionEnabled" = false;
  "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;

  "toolkit.telemetry.enabled" = false;
  "toolkit.telemetry.unified" = false;
  "toolkit.telemetry.server" = "data:,";
  "toolkit.telemetry.archive.enabled" = false;
  "toolkit.telemetry.newProfilePing.enabled" = false;
  "toolkit.telemetry.shutdownPingSender.enabled" = false;
  "toolkit.telemetry.updatePing.enabled" = false;
  "toolkit.telemetry.bhrPing.enabled" = false;
  "toolkit.telemetry.firstShutdownPing.enabled" = false;
  "toolkit.telemetry.coverage.opt-out" = true;

  "toolkit.coverage.opt-out" = true;
  "toolkit.coverage.endpoint.base" = "";

  "browser.newtabpage.activity-stream.telemetry" = false;
  "browser.ping-centre.telemetry" = false;

  "breakpad.reportURL" = "";
  "browser.tabs.crashReporting.sendReport" = false;
  "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

  /**
   *************************************************************************
  * Permissions defaults                                                     *
  **************************************************************************
  */
  # 0=always ask (default), 1=allow, 2=block
  "permissions.default.geo" = 0;
  "permissions.default.camera" = 0;
  "permissions.default.microphone" = 0;
  "permissions.default.desktop-notification" = 0;
  "permissions.default.xr" = 0; # Virtual Reality

  "dom.webnotifications.enabled" = false;
  "dom.webnotifications.serviceworker.enabled" = false;

  /**
   *************************************************************************
  * Performance / media                                                      *
  **************************************************************************
  */
  "gfx.webrender.all" = true; # Force enable GPU acceleration
  "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes
  "media.ffmpeg.vaapi.enabled" = true;
  "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
  "privacy.webrtc.legacyGlobalIndicator" = false;
  "reader.parse-on-load.force-enabled" = true;

  "network.http.http3.enabled" = true;

  /**
   *************************************************************************
  * Zen-specific UI prefs                                                    *
  **************************************************************************
  */
  "layout.css.devPixelsPerPx" = -1;

  "browser.ssb.enabled" = true;
  "browser.tabs.allow_transparent_browser" = true;

  "zen.window-sync.enabled" = true; # Decouple from windows and instead couple tabs to spaces

  # Not using https://sameerasw.com/zen#intro anymore so now set to false
  "zen.theme.acrylic-elements" = false;
  "widget.transparent-windows" = false;
  "zen.theme.gradient.show-custom-colors" = false;

  # "zen.theme.accent-color" = "#FFFFFF"; # Doesn't work?
  "zen.theme.border-radius" = 8;
  "zen.theme.content-element-separation" = 0;
  "zen.theme.dark-mode-bias" = 0.3;
  "zen.theme.essentials-favicon-bg" = true;
  "zen.theme.gradient" = true;
  "zen.theme.hide-tab-throbber" = true;
  "zen.theme.show-custom-colors" = true;
  "zen.theme.styled-status-panel" = false;
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
  "zen.welcome-screen.seen" = true;
  "zen.widget.linux.transparency" = false; # Disable transparent sidebar
  "zen.workspaces.continue-where-left-off" = true;

  # I actually prefer this a lot for a few reasons, 1 being my browser is on my right monitor and so I can just yeet my cursor to the edge of the screen and it'll bring up the tabs sidebar, but if it's on the left there's a risk I do that and the cursor just moves onto my monitor on the left. And also it doesn't cover up a lot of navigation things on pages which tend to be on the left, at least in my experience.
  "zen.tabs.vertical.right-side" = true;
  "theme.floating_history.position" = "left";
  "layout.scrollbar.side" = 3;

  "uc.tabs.dim_unloaded" = true; # For Better Tab Indicators extension

  /**
   *************************************************************************
  * Optional ideas (commented out)                                           *
  **************************************************************************
  */
  # UI customization state is a large JSON blob; declare only if you want fully
  # reproducible toolbar layouts.
  # "browser.uiCustomization.state" = builtins.toJSON { };

  # More hardening (can break some sites / make debugging harder):
  # "privacy.firstparty.isolate" = true;
  # "privacy.partition.network_state" = true;
  # "privacy.sanitize.sanitizeOnShutdown" = lockTrue;
  # "browser.sessionstore.privacy_level" = 2;
}
