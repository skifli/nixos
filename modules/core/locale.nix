{ hostVars, ... }:

{
  console.keyMap = hostVars.consoleKeymap; # Defines for virtual console (TUI not GUI)
  i18n = {
    defaultLocale = hostVars.locale;
    extraLocaleSettings = {
      LC_ADDRESS = hostVars.locale;
      LC_IDENTIFICATION = hostVars.locale;
      LC_MEASUREMENT = hostVars.locale;
      LC_MONETARY = hostVars.locale;
      LC_NAME = hostVars.locale;
      LC_NUMERIC = hostVars.locale;
      LC_PAPER = hostVars.locale;
      LC_TELEPHONE = hostVars.locale;
      LC_TIME = hostVars.locale;
    };
  };

  time.timeZone = hostVars.timezone;
}
