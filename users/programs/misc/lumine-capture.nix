{
  pkgs,
  userVars,
  ...
}:
let
  lumine-capture = pkgs.stdenv.mkDerivation {
    pname = "lumine-capture";
    version = "0.5.0";

    src = pkgs.fetchurl {
      url =
        if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
          "https://github.com/Netflate/LumineCapture/releases/download/v0.5.0/lumine-capture_0.5.0-1_amd64.deb"
        else
          "https://github.com/Netflate/LumineCapture/releases/download/v0.5.0/lumine-capture_0.5.0-1_arm64.deb";
      hash =
        if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
          "sha256-DkTe2O0lTB2l4GYnBNP7m+81WqOrFh9bo6SSBcF1byI="
        else
          "sha256-J+WfFgOk26SX9i3HkCqY5YCFc7TaI7hiw1C13PJR3Sc=";
    };

    nativeBuildInputs = [
      pkgs.dpkg
      pkgs.makeWrapper
    ];

    installPhase = ''
            dpkg-deb -x $src $out
            install -Dm755 $out/usr/bin/lumine-capture $out/bin/lumine-capture
            wrapProgram $out/bin/lumine-capture \
              --prefix LD_LIBRARY_PATH : ${
                builtins.toString (
                  builtins.foldl' (acc: p: acc + p + "/lib:") "" [
                    pkgs.openssl
                    pkgs.libxkbcommon
                    pkgs.pipewire
                    pkgs.wayland
                    pkgs.libGL
                    pkgs.vulkan-loader
                  ]
                )
              }
            install -Dm644 $out/usr/share/applications/lumine-capture.desktop \
              $out/share/applications/lumine-capture.desktop
            substituteInPlace $out/share/applications/lumine-capture.desktop \
              --replace 'Exec=/usr/bin/lumine-capture' "Exec=$out/bin/lumine-capture"
            cp -r $out/usr/share/icons $out/share/
            # Install default config for selection.remember = "off"
            mkdir -p $out/share/lumine-capture
            cat > $out/share/lumine-capture/default-config.toml <<EOF
      [selection]
      remember = "off"
      EOF
    '';

    meta = with pkgs.lib; {
      description = "Fast, lightweight Wayland screenshot tool";
      homepage = "https://github.com/Netflate/LumineCapture";
      license = [
        licenses.mit
        licenses.asl20
        licenses.ofl
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      mainProgram = "lumine-capture";
    };
  };
in
{
  home-manager.users.${userVars.username} = {
    # https://github.com/Netflate/LumineCapture
    home.packages = [ lumine-capture ];
  };
}
