{
  pkgs,
  userVars,
  ...
}:
let
  lumine-capture = pkgs.stdenv.mkDerivation {
    pname = "lumine-capture";
    version = "0.3.0";

    src = pkgs.fetchurl {
      url =
        if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
          "https://github.com/Netflate/LumineCapture/releases/download/v0.3.0/lumine-capture_0.3.0-1_amd64.deb"
        else
          "https://github.com/Netflate/LumineCapture/releases/download/v0.3.0/lumine-capture_0.3.0-1_arm64.deb";
      hash =
        if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
          "sha256-w97zkBbBquCn2Oetrix2arFs+YYcAbeUzvg/AzGE5Yg="
        else
          "sha256-onxvQAayz47gsY84SWP320prp4pKdckPc+QX4ItF4Jw=";
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
