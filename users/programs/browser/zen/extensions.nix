{hostVars, ...}:
# Extension policy wiring for zen-browser-flake.
# Learn more:
# https://github.com/0xc000022070/zen-browser-flake/tree/b6b1e625e4aa049b59930611fc20790c0ccbc840?tab=readme-ov-file#extensions
let
  mkAmoXpiUrl = amoSlug: "https://addons.mozilla.org/firefox/downloads/latest/${amoSlug}/latest.xpi";

  mkForceInstalled = {
    amoSlug,
    pinned ? false,
  }:
    {
      install_url = mkAmoXpiUrl amoSlug;
      installation_mode = "force_installed";
    }
    // (
      if pinned
      then {default_area = "navbar";}
      else {}
    );

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
in {
  ExtensionSettings =
    {
      "*" = {
        blocked_install_message = "The addon you are trying to install is not added in the Nix config";
        installation_mode = "blocked";
      };
    }
    // extensionSettingsFromAmo
    // customExtensionSettings;

  "3rdparty".Extensions = {
    # Dunno if these actually work but still
    "{ef87d84c-2127-493f-b952-5b4e744245bc}" = {
      "baseUrl" = "http://0.0.0.0:5600";
      browserName = "zen";
      consent = true;
      consentRequired = true;
      enabled = true;
      inherit (hostVars) hostname;
      lastSyncSuccess = true;
    };
    "adnauseam@rednoise.org" = {
      blockingMalware = true;
      clickingAds = true;
      firstInstall = false;
      hidingAds = true;
    };
  };
}
