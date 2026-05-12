{hostVars, ...}: let
  extensions = import ./extensions.nix {inherit hostVars;};

  lockPref = value: {
    Value = value;
    Status = "locked";
  };
in
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
      Allow = [];
      Default = true;
      Locked = false;
    };
    Preferences = {
      "browser.tabs.warnOnClose" = {
        Value = false;
      };

      # Keep most UI preferences user-changeable (defaults go in profile settings).
      # These are the ones we actually want enforced.
      "dom.security.https_only_mode" = lockPref true;
      "dom.security.https_only_mode_ever_enabled" = lockPref true;

      "privacy.globalprivacycontrol.enabled" = lockPref true;
      "privacy.globalprivacycontrol.functionality.enabled" = lockPref true;

      "extensions.autoDisableScopes" = lockPref 0;
      "extensions.enabledScopes" = lockPref 15;
      "extensions.webextensions.restrictedDomains" = lockPref "";
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
    # Learn more:
    # https://github.com/0xc000022070/zen-browser-flake/tree/b6b1e625e4aa049b59930611fc20790c0ccbc840?tab=readme-ov-file#extensions
  }
  // extensions
