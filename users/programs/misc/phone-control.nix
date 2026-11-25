{
  commonHostVars,
  lib,
  pkgs,
  userVars,
  ...
}:
let
  phone = commonHostVars.tailscaleDevices.oneplus-be2013;
  phoneTarget = "${phone.address}:${toString phone.adbPort}";
  scrcpyIcon = "${pkgs.scrcpy}/share/icons/hicolor/256x256/apps/scrcpy.png";

  phoneControl = pkgs.writeShellApplication {
    name = "phone-control";
    runtimeInputs = [
      pkgs.android-tools
      pkgs.coreutils
      pkgs.jq
      pkgs.libnotify
      pkgs.niri
      pkgs.scrcpy
    ];
    text = ''
      target=${lib.escapeShellArg phoneTarget}
      # scrcpy resizes its SDL window after the initial map, which can override
      # Niri's default-window-height. Pass the same 75% size to scrcpy itself.
      window_height="$(niri msg -j focused-output | jq -er '(.logical.height * 0.75) | floor')"
      notify-send -e -t 2500 -a "Phone Control" \
        -i ${lib.escapeShellArg scrcpyIcon} -u low \
        "Connecting to phone" "Connecting over Tailscale…"

      # The phone's ADB daemon is already listening on its Tailscale address.
      adb connect "$target" >/dev/null 2>&1 || true

      connected=false
      for _ in {1..24}; do
        if [ "$(adb -s "$target" get-state 2>/dev/null || true)" = "device" ]; then
          connected=true
          break
        fi
        sleep 0.25
      done

      if [ "$connected" != true ]; then
        notify-send -a "Phone Control" -i ${lib.escapeShellArg scrcpyIcon} -u critical \
          "Phone unavailable" \
          "Check that Tailscale is connected and the phone's ADB service is running."
        exit 1
      fi

      exec scrcpy \
        --serial="$target" \
        --window-title="Phone" \
        --shortcut-mod=lalt \
        --window-height="$window_height" \
        --audio-source=output \
        --max-size=1280 \
        --max-fps=30 \
        --video-bit-rate=8M
    '';
  };
in
{
  home-manager.users.${userVars.username} = {
    home.packages = [ phoneControl ];

    xdg.desktopEntries.phone-control = {
      name = "Phone Control";
      genericName = "Control phone over Tailscale";
      exec = "${phoneControl}/bin/phone-control";
      icon = scrcpyIcon;
      categories = [
        "Utility"
        "RemoteAccess"
      ];
      terminal = false;
    };
  };
}
