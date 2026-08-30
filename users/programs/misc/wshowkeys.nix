{
  commonHostVars,
  inputs,
  pkgs,
  userVars,
  ...
}: let
  wshowkeysPkg = inputs.wshowkeys.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  # Enable setuid wrapper for wshowkeys (required to read /dev/input events)
  programs.wshowkeys = {
    enable = true;
    package = wshowkeysPkg;
  };

  home-manager.users.${userVars.username} = {
    # Provide a toggle helper script in PATH
    home.packages = [
      (pkgs.writeShellScriptBin "toggle-wshowkeys" ''
        if ${pkgs.procps}/bin/pgrep -x wshowkeys >/dev/null; then
            ${pkgs.procps}/bin/pkill -x wshowkeys
            ${pkgs.libnotify}/bin/notify-send -e -a wshowkeys -i "/home/${userVars.username}/.local/share/misc/keycap-asterisk-svgrepo-com.svg" -u low -t 1500 "Keystroke overlay" "Stopped wshowkeys"
        else
            /run/wrappers/bin/wshowkeys \
                -a bottom \
                -m 40 \
                -F '${commonHostVars.fonts.sansSerif.name} Bold 22' \
                -b '#1e1e2edd' \
                -f '#cdd6f4ff' \
                -s '#f38ba8ff' \
                -t 1200 \
                -l 650 \
                -M \
                -U \
                -S &
            ${pkgs.libnotify}/bin/notify-send -e -a wshowkeys -i "/home/${userVars.username}/.local/share/misc/keycap-asterisk-svgrepo-com.svg" -u low -t 1500 "Keystroke overlay" "Started wshowkeys"
        fi
      '')
    ];
  };
}
