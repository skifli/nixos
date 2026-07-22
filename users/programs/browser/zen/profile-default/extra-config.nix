{inputs}: ''
  /****************************************************************************
   * BETTERFOX                                                                 *
  ****************************************************************************/
  // This injects Betterfox's opinionated defaults, then layers our overrides.
  // Keeping it in a separate file makes zen.nix/profile wiring much easier.

  // ${builtins.readFile "${inputs.betterfox}/user.js"}
  // (Importing these separately is nicer than the monolithic user.js.)
  ${builtins.readFile "${inputs.betterfox}/Fastfox.js"}
  ${builtins.readFile "${inputs.betterfox}/Securefox.js"}
  ${builtins.readFile "${inputs.betterfox}/Peskyfox.js"}

  /****************************************************************************
   * MY OVERRIDES                                                              *
  ****************************************************************************/
  // Visit:
  // - https://github.com/yokoffing/Betterfox/wiki/Common-Overrides
  // - https://github.com/yokoffing/Betterfox/wiki/Optional-Hardening

  // Common overrides
  // Avoid forcing strict content blocking; keep site compatibility high.
  // ETP mode is driven by enterprise policy (standard).

  // Privacy: disable local/ML previews (can cause extra processing and is rarely needed).
  user_pref("browser.ml.linkPreview.enabled", false);

  // Optional hardening
  user_pref("identity.fxaccounts.enabled", false); // Disable Firefox Sync
  user_pref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");

  user_pref("signon.rememberSignons", false);
  user_pref("extensions.formautofill.addresses.enabled", false);
  user_pref("extensions.formautofill.creditCards.enabled", false);

  user_pref("browser.download.useDownloadDir", false);
  user_pref("browser.download.always_ask_before_handling_new_types", false);
  user_pref("extensions.postDownloadThirdPartyPrompt", false);

  // Certificate pinning: keep the default behavior for compatibility.
  // (Strict mode can cause issues on networks with TLS interception.)
  user_pref("security.cert_pinning.enforcement_level", 1);

  /****************************************************************************
   * SMOOTHFOX                                                                 *
  ****************************************************************************/
  // See: https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js

  // Recommended for 60hz+ displays
  user_pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
  user_pref("general.smoothScroll", true); // DEFAULT
  user_pref("mousewheel.default.delta_multiplier_y", 275); // 250-400

  // Firefox Nightly only:
  // user_pref("general.smoothScroll.msdPhysics.enabled", false); // [FF122+ Nightly]
''
