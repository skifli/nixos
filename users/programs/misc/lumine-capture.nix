{
  inputs,
  pkgs,
  userVars,
  ...
}:
let
  lumineCapturePkg = inputs.lumine-capture.packages.${pkgs.stdenv.hostPlatform.system}.default;
  lumineCaptureWithConfig = lumineCapturePkg.overrideAttrs (old: {
    postInstall = ''
      ${old.postInstall or ""}
      mkdir -p "$out/share/lumine-capture"
      cat > "$out/share/lumine-capture/default-config.toml" <<'EOF'
      [selection]
      remember = "off"
      EOF
    '';
  });
in
{
  home-manager.users.${userVars.username}.home.packages = [ lumineCaptureWithConfig ];
}
