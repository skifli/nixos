{
  pkgs,
  userVars,
  ...
}:
let
  waynavPkg =
    pkgs.waynav or (pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "waynav";
      version = "1.4.0";

      src = pkgs.fetchFromGitHub {
        owner = "kovetskiy";
        repo = "waynav";
        rev = finalAttrs.version;
        hash = "sha256-L7l3zV4Z451SESFjdq3BVoCgRiAJCuTDI74q7fdVTfQ=";
      };

      nativeBuildInputs = with pkgs; [
        meson
        ninja
        pkg-config
        wayland-scanner
      ];

      buildInputs = with pkgs; [
        wayland
        wayland-protocols
        libxkbcommon
        cairo
      ];

      meta = {
        description = "Wayland-native grid-based keyboard mouse navigator";
        homepage = "https://github.com/kovetskiy/waynav";
        license = pkgs.lib.licenses.mit;
        platforms = pkgs.lib.platforms.linux;
        mainProgram = "waynav";
      };
    }));
in
{
  home-manager.users.${userVars.username} = {
    home.packages = [
      waynavPkg
    ];

    # Declarative waynavrc configuration
    xdg.configFile."waynav/waynavrc".text = ''
      # Clear default bindings
      clear

      # Visual style
      line-width 2.0
      grid-color 8992a7cc   # Subtle bluish-grey grid (semi-transparent)
      region-bg  00000020   # Very faint dark backdrop tint

      # Initial 2x2 grid when triggered
      super+semicolon start,grid 2x2

      # Quadrant selection
      q cell-select 1,warp
      a cell-select 2,warp
      w cell-select 3,warp
      s cell-select 4,warp

      # 3x3 grid mode (press g to split current cell into 3x3)
      g grid 3x3

      # Micro-adjustments with Vim keys
      h move-left,warp
      j move-down,warp
      k move-up,warp
      l move-right,warp

      # Left click & exit
      space warp,click 1,end
      Return warp,click 1,end

      # Right click & exit
      r warp,click 3,end

      # Middle click & Exit
      m warp,click 2,end

      # Double click
      d warp,click 1,click 1,end

      # Navigation & cancel
      BackSpace history-back
      Escape end
      semicolon end
    '';
  };
}
