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
}
