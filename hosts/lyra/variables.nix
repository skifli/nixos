{
  # Feature toggles
  # disableX = true;

  # Host configuration
  enabledImports = [
    # Host specific modules
    ../../modules/core/audio.nix
    ../../modules/core/boot.nix
    ../../modules/core/fonts.nix
    ../../modules/core/locale.nix
    ../../modules/core/networking.nix
    ../../modules/core/printing.nix
    ../../modules/core/security.nix
    ../../modules/core/services.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix

    ../../modules/hardware/graphics.nix

    ../../modules/programs/clamav.nix
  ];

  # User configuration
  enabledUsers = [ "ami" ];

  # Hardware configuration
  videoDriver = "intel"; # Empty to import none.
  outputs = {
    "ROW-AAA" = {
      name = "desc:ROW AAA";
      mode = {
        width = 1440;
        height = 900;
        refresh = 59.89;
      };
      position = {
        x = 0;
        y = 0;
      };
    };
    "Acer-KG241Q" = {
      name = "desc:Acer Technologies Acer KG241Q 0x92918EF5";
      mode = {
        width = 1920;
        height = 1080;
        refresh = 74.99;
      };
      position = {
        x = 1440; # Right of the first monitor
        y = 0;
      };
      focus-at-startup = true;
    };
  };
  workspaces = {
    "1" = {
      open-on-output = "Acer-KG241Q";
    };
    "3" = {
      open-on-output = "Acer-KG241Q";
    };
    "5" = {
      open-on-output = "Acer-KG241Q";
    };
    "7" = {
      open-on-output = "Acer-KG241Q";
    };
    "9" = {
      open-on-output = "Acer-KG241Q";
    };

    "2" = {
      open-on-output = "ROW-AAA";
    };
    "4" = {
      open-on-output = "ROW-AAA";
    };
    "6" = {
      open-on-output = "ROW-AAA";
    };
    "8" = {
      open-on-output = "ROW-AAA";
    };
    "10" = {
      open-on-output = "ROW-AAA";
    };
  };

  screen-lock-timeout = 5;
  screen-blank-timeout = 15;

  # Localisation
  consoleKeymap = "uk"; # TTY keymap
  keyboardLayout = "gb"; # Keyboard layout

  kbdVariant = "extd"; # Keyboard variant (can be empty)

  latitude = 51.5;
  longitude = -0.1;

  locale = "en_GB.UTF-8"; # System locale

  timezone = "Europe/London"; # Your timezone
}
