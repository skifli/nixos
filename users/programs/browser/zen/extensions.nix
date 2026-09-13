{ ... }:
# Extension policy wiring for zen-browser-flake.
# Learn more:
# https://github.com/0xc000022070/zen-browser-flake/tree/b6b1e625e4aa049b59930611fc20790c0ccbc840?tab=readme-ov-file#extensions
let
  mkAmoXpiUrl = amoSlug: "https://addons.mozilla.org/firefox/downloads/latest/${amoSlug}/latest.xpi";

  mkForceInstalled =
    {
      amoSlug,
      pinned ? false,
    }:
    {
      install_url = mkAmoXpiUrl amoSlug;
      installation_mode = "force_installed";
    }
    // (if pinned then { default_area = "navbar"; } else { });

  # Mapping: extension-id to { amoSlug, pinned? }
  # The attribute name is the extension ID; the slug is used to fetch from AMO.
  amoExtensions = {
    "{ef87d84c-2127-493f-b952-5b4e744245bc}" = {
      amoSlug = "aw-watcher-web";
    };
    "adnauseam@rednoise.org" = {
      amoSlug = "adnauseam";
    };
    "authenticator@mymindstorm" = {
      amoSlug = "auth-helper";
    };
    "firefox@vicinae.com" = {
      amoSlug = "vicinae";
    };
    "anti-social@conniptions.org" = {
      amoSlug = "anti-social-blocker";
    };
    "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
      amoSlug = "proton-pass";
    };
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
      amoSlug = "vimium-ff";
    };
  };

  extensionSettingsFromAmo = builtins.mapAttrs (_: mkForceInstalled) amoExtensions;

  customExtensionSettings = {
    # View XPI IDs in the Firefox Extension Store (or upstream release pages)
    "queryamoid@kaply.com" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
    };
  };
in
{
  ExtensionSettings = {
    "*" = {
      blocked_install_message = "The addon you are trying to install is not added in the Nix config";
      installation_mode = "blocked";
    };
  }
  // extensionSettingsFromAmo
  // customExtensionSettings;

  "3rdparty".Extensions = {
    # Firefox managed storage (`browser.storage.managed`), coming from the `3rdparty`
    # policy. It ONLY affects extensions that actually read
    # `browser.storage.managed`. Most extensions - including every one below -
    # read their settings from `browser.storage.local` instead, so keys set here
    # for them are just ignored. I checked all of the below ones against the repo
    # source (September 2026); mistaken keys are kept as comments so the old
    # (wrong) intent is not not here, so I can see how stupid I was in the future!!
    # /j.

    # ---- aw-watcher-web ---------------------------------------------------------
    # REAL: `consentOfflineDataCollection`. background/main.ts reads ONLY this one
    # key from managed storage; `true` pre-accepts the Firefox privacy-consent
    # popup (otherwise a consent tab opens and the extension starts disabled).
    # DEAD: baseUrl, browserName, hostname, consent, consentRequired, enabled,
    #   lastSyncSuccess - all read thru browser.storage.local (src/storage.ts).
    "{ef87d84c-2127-493f-b952-5b4e744245bc}" = {
      consentOfflineDataCollection = true;

      # DEAD - the extension never reads these from managed storage:
      # "baseUrl" = "http://0.0.0.0:5600";
      # browserName = "zen";
      # consent = true;
      # consentRequired = true;
      # enabled = true;
      # inherit (hostVars) hostname;
      # lastSyncSuccess = true;
    };

    # ---- AdNauseam --------------------------------------------------------------
    # Reads NO managed storage at all (zero `storage.managed` references in the
    # source). Its ad settings are in uBO's `userSettings` (background.js
    # defaults: hidingAds/clickingAds/blockingMalware/firstInstall) persisted to
    # browser.storage.local, so nothing here is used ;-;. The first-run setup page
    # (firstrun.html) is based on `firstInstall`, a runtime-derived flag, not a
    # stored value - can't be suppressed from here either breuh.
    # NOTE: `blockingMalware` is INVERTED naming - `true` DISABLES ad blocking
    # (core.js blocks while `blockingMalware === false`). What.
    "adnauseam@rednoise.org" = {
      # DEAD - all kaboom (and `blockingMalware = true` would actually DISABLE blocking):
      # blockingMalware = true;
      # clickingAds = true;
      # firstInstall = false;
      # hidingAds = true;
    };

    # ---- Everything below reads its own private storage (browser.storage.local
    # or a third-party/central account store), never `storage.managed`, so there
    # is moothing to configure here. Empty stubs kept to show they were checked;
    # only the extension author could add managed-storage support to change this.

    # auth-helper (MyMindstorm 2FA backup) - settings in its own options UI
    "authenticator@mymindstorm" = {
    };

    # vicinae launcher companion (own extension) - comms to the local vicinae
    # server, settings elsewhere; could be made managed-aware if desired
    "firefox@vicinae.com" = {
    };

    # anti-social-blocker (wgmyers/anti-social) - settings in browser.storage.local
    # (blockOnFlag, settings)
    "anti-social@conniptions.org" = {
    };

    # proton-pass - Proton-internal storage
    "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
    };

    # vimium-ff (philc/vimium) - options in webextension storage
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
    };

    # query-amoid (mkaply) - no settings outside its popup
    "queryamoid@kaply.com" = {
    };
  };
}
