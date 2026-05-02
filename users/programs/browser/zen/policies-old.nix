{ ... }:

{
  AllowFileSelectionDialogs = true;
  AppAutoUpdate = false;
  AutofillAddressEnabled = false;
  AutofillCreditCardEnabled = false;
  # AutoLaunchProtocolsFromOrigins = { };
  BackgroundAppUpdate = false;
  BlockAboutAddons = false;
  BlockAboutConfig = false;
  BlockAboutProfiles = false;
  BlockAboutSupport = false;
  # Containers = { };
  DisableAppUpdate = true;
  DisableFirefoxAccounts = true;
  DisableFirefoxScreenshots = true;
  DisableFirefoxStudies = true;
  DisableFormHistory = true;
  DisableMasterPasswordCreation = true;
  DisablePocket = true;
  DisablePrivateBrowsing = false;
  DisableProfileImport = false;
  DisableProfileRefresh = false;
  DisableSafeMode = false;
  DisableTelemetry = true;
  DisableFeedbackCommands = true;
  DontCheckDefaultBrowser = true;
  DNSOverHTTPS = {
    Enabled = true;
  };
  EnableTrackingProtection = {
    Value = true;
    Locked = true;
    Cryptomining = true;
    Fingerprinting = true;
  };
  EncryptedMediaExtensions = {
    Enabled = true;
  };
  ExtensionUpdate = true;
  FirefoxHome = {
    Search = false;
    TopSites = false;
    SponsoredTopSites = false;
    Highlights = false;
    Pocket = false;
    SponsoredPocket = false;
    Snippets = false;
    Locked = false;
  };
  HardwareAcceleration = true;
  ManualAppUpdateOnly = true;
  NoDefaultBookmarks = false;
  OfferToSaveLogins = false;
  PasswordManagerEnabled = false;
  PictureInPicture = {
    Enabled = true;
  };
  PopupBlocking = {
    Allow = [ ];
    Default = true;
    Locked = false;
  };
  Preferences = {
    "browser.tabs.warnOnClose" = {
      Value = false;
    };
  };
  PromptForDownloadLocation = true;
  RequestPolicy = {
    EnableTrackingProtection = true;
    Default = "standard";
  };
  SearchSuggestEnabled = false;
  ShowHomeButton = false;
  StartDownloadsInTempDirectory = false;
  UserMessaging = {
    ExtensionRecommendations = false;
    SkipOnboarding = true;
  };
  ExtensionSettings = {
    "*" = {
      blocked_install_message = "The addon you are trying to install is not added in the nix config";
      installation_mode = "blocked";
    };
    "adnauseam@rednoise.org" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/adnauseam/latest.xpi";
    };
    "authenticator@mymindstorm" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/auth-helper/latest.xpi";
    };
    "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
    };
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
    };
    "{7c1aa46e-b74f-4325-95d2-84c07d19cdce}" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-scheduler-auto-open-close/latest.xpi";
    };
    "addon@darkreader.org" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
    };
    "Tab-Session-Manager@sienori" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-session-manager/latest.xpi";
    };
    # View Xpi Id's in Firefox Extension Store
    "queryamoid@kaply.com" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
    };
  };
  "3rdparty".Extensions = {
    "addon@darkreader.org" = {
      enabled = true;
      automation = {
        enabled = true;
        behavior = "OnOff";
        mode = "system";
      };

      detectDarkTheme = true;
      enabledByDefault = true;
      changeBrowserTheme = true;
      enableForProtectedPages = true;
      fetchNews = true;
      syncSitesFixes = true;
      previewNewDesign = true;
      # previewNewestDesign = true; # TODO: Mayhaps test

      # enabledFor = [];
      # disabledFor = [];
    };
    "adnauseam@rednoise.org" = {
      enabled = true;
      firstInstall = false;
      hidingAds = true;
      clickingAds = true;
      blockingMalware = true;
    };
  };
}

