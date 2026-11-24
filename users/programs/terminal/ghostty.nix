{
  commonHostVars,
  lib,
  pkgs,
  userVars,
  ...
}:
let
  # Generate both Ghostty themes from base16 directly instead of using the
  # Stylix theme. Stylix only knows the palette of the currently active
  # light/dark specialisation, but Ghostty needs both palettes present at once
  # so it can switch itself without waiting for a Home Manager reload.
  #
  # The base16 scheme files are tiny, fixed-format YAML, so parse just the
  # palette lines instead of pulling in a YAML parser.
  paletteFor =
    name:
    let
      yaml = builtins.readFile "${pkgs.base16-schemes}/share/themes/${name}.yaml";
      matchLine = line: builtins.match "  (base0[0-9A-F]): \"#([0-9a-fA-F]{6})\"" line;
      matches = builtins.filter (m: m != null) (map matchLine (lib.splitString "\n" yaml));
    in
    builtins.listToAttrs (
      map (m: lib.nameValuePair (builtins.elemAt m 0) (builtins.elemAt m 1)) matches
    );

  hexFor = colors: key: lib.removePrefix "#" colors.${key};

  mkTheme =
    scheme:
    let
      colors = paletteFor scheme;
      hex = hexFor colors;
    in
    {
      background = hex "base00";
      foreground = hex "base05";
      cursor-color = hex "base05";
      selection-background = hex "base02";
      selection-foreground = hex "base05";

      palette = [
        "0=${hex "base00"}"
        "1=${hex "base08"}"
        "2=${hex "base0B"}"
        "3=${hex "base0A"}"
        "4=${hex "base0D"}"
        "5=${hex "base0E"}"
        "6=${hex "base0C"}"
        "7=${hex "base05"}"
        "8=${hex "base03"}"
        "9=${hex "base08"}"
        "10=${hex "base0B"}"
        "11=${hex "base0A"}"
        "12=${hex "base0D"}"
        "13=${hex "base0E"}"
        "14=${hex "base0C"}"
        "15=${hex "base07"}"
      ];
    };
in
{
  home-manager.users.${userVars.username} = {
    programs.ghostty = {
      enable = true;
      # TODO: Future, https://ghostty.org/docs/features/ssh - alias ssh to "ghostty +ssh --".
      enableZshIntegration = userVars.programs.terminal-shell == "zsh";
      settings = {
        desktop-notifications = true;
        notify-on-command-finish = "unfocused";
        notify-on-command-finish-action = "bell,notify";
        bell-features = "system";
        link-url = true;
        link-previews = true;
        gtk-single-instance = true;
        # KDE's "Open Terminal Here" launches Ghostty from the selected
        # directory; avoid Ghostty's desktop-launch fallback to $HOME.
        working-directory = "inherit";

        # Both themes are always installed, so Ghostty's own light/dark
        # detection (which follows the portal live) can pick the right one.
        # mkForce because the Stylix Ghostty target sets `theme = "stylix"`.
        theme = lib.mkForce "light:stylix-light,dark:stylix-dark";
      };
      themes = {
        stylix-light = mkTheme commonHostVars.theme.light;
        stylix-dark = mkTheme commonHostVars.theme.dark;
      };
      systemd.enable = true; # Nyoom startup times
    };

    # Dolphin resolves TerminalService via the user's local applications
    # directory. Putting this only in the Nix profile makes Dolphin's built-in
    # "Open Terminal Here" fall back to an iconless action on this setup.
    # Keep the entry category-free (so it stays out of the app launcher) and
    # non-single-instance (so Dolphin's working directory is preserved).
    home.file.".local/share/applications/ghostty-terminal.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Ghostty
      Exec=${pkgs.ghostty}/bin/ghostty --gtk-single-instance=false
      Icon=utilities-terminal
      Terminal=false
      DBusActivatable=false
    '';
  };
}
