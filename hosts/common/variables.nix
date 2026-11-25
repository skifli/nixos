{ pkgs, ... }: {
  cursor = {
    package = pkgs.bibata-cursors;
    size = 12;
    light.name = "Bibata-Modern-Ice";
    dark.name = "Bibata-Modern-Classic";
  };
  fonts = {
    sansSerif = {
      name = "Inter";
      package = pkgs.inter;
    };
    serif = {
      name = "Inter";
      package = pkgs.inter;
    };

    monospace = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };

    sizes = {
      applications = 10;
      desktop = 9;
      popups = 9;
      terminal = 9;
    };
  };
  icons = {
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
    light = "Papirus-Light";
  };
  theme = {
    light = "tomorrow";
    dark = "tomorrow-night";

    # GTK stuff
    gtk = {
      package = pkgs.adw-gtk3;
      lightName = "adw-gtk3";
      darkName = "adw-gtk3-dark";
    };

    qt = {
      platformTheme = "kde";
      style = "breeze";
    };
  };
  shellAliases = { };
  tailscaleDevices = {
    fydetabduo = {
      address = "100.107.134.34";
      sshUser = "fynix";
    };
    lenovo-a2016a40 = {
      address = "100.103.254.124";
      sshUser = null;
    };
    lyra = {
      address = "100.76.87.14";
      sshUser = "ami";
    };
    oneplus-be2013 = {
      address = "100.71.197.78";
      adbPort = 42069;
      sshUser = null;
    };
    oracle-nix = {
      address = "100.78.161.125";
      sshUser = "nixci";
    };
    pifi = {
      address = "100.88.68.91";
      sshUser = "root";
    };
    pistor = {
      address = "100.90.46.33";
      sshUser = "root";
    };
  };
  sessionVariables = {
    AWWW_TRANSITION = "none"; # Sorry - it's annoying (especially on the FydeTab Duo on rotate!)
  };
}
