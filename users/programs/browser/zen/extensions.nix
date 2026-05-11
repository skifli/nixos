{ hostVars, ... }:

# Learn more:
# https://github.com/0xc000022070/zen-browser-flake/tree/b6b1e625e4aa049b59930611fc20790c0ccbc840?tab=readme-ov-file#extensions
let
  mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

  mkExtensionEntry =
    {
      id,
      pinned ? false,
    }:
    let
      base = {
        install_url = mkPluginUrl id;
        installation_mode = "force_installed";
      };
    in
    if pinned then base // { default_area = "navbar"; } else base;

  mkExtensionSettings = builtins.mapAttrs (
    _: entry: if builtins.isAttrs entry then entry else mkExtensionEntry { id = entry; }
  );

  # Follows pattern "extension-ID" = "extension-name";
  mozillaExtensionIds = {
    "{91aa3897-2634-4a8a-9092-279db23a7689}".id = "zen-internet";
    "{ef87d84c-2127-493f-b952-5b4e744245bc}".id = "aw-watcher-web";
    "adnauseam@rednoise.org".id = "adnauseam";
    "authenticator@mymindstorm".id = "auth-helper";
    "78272b6fa58f4a1abaac99321d503a20@proton.me".id = "proton-pass";
  };

  customExtensionSettings = {
    # View Xpi Id's in Firefox Extension Store
    "queryamoid@kaply.com" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
    };
  };
in
{
  ExtensionSettings =
    {
      "*" = {
        blocked_install_message = "The addon you are trying to install is not added in the Nix config";
        installation_mode = "blocked";
      };
    }
    // mkExtensionSettings mozillaExtensionIds
    // mkExtensionSettings customExtensionSettings;

  "3rdparty".Extensions = {
    # Dunno if these actually work but still
    "{91aa3897-2634-4a8a-9092-279db23a7689}" = {
      "transparentZenSettings" = {
        enableStyling = true;
        autoUpdate = true;
        forceStyling = true;
        whitelistMode = false;
        whitelistStyleMode = false;
        disableTransparency = false;
        disableHover = false;
        disableFooter = false;
        disableDarkReader = false;
        enableLogs = false;
        fallbackBackgroundList = [];
        lastFetchedTime = 0;
        welcomeShown = true;
      };
    };
    "{ef87d84c-2127-493f-b952-5b4e744245bc}" = {
      "baseUrl" = "http://0.0.0.0:5600";
      browserName = "zen";
      consent = true;
      consentRequired = true;
      enabled = true;
      hostname = hostVars.hostname;
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
