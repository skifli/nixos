{
  hostVars,
  lib,
  pkgs,
  userVars,
  ...
}: let
  # Map standard Linux keyboard layouts to Remmina's RDP LCID decimal codes
  rdpLayoutMap = {
    "gb" = "809";
    "uk" = "809";
    "us" = "409";
  };
  
  # Look up hostVars.keyboardLayout
  rdpCode = rdpLayoutMap.${hostVars.keyboardLayout};
in {
  home-manager.users.${userVars.username} = {lib, ...}: {
    home = {
      packages = with pkgs; [
        remmina
      ];

      activation.setRemminaKeyboard = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Make it use the desired keyboard layout
        sed -i 's/^rdp_keyboard_layout.*/rdp_keyboard_layout=${rdpCode}/' "$HOME/.config/remmina/remmina.pref"

        # Don't passthrough Windows / mod key
        sed -i 's/^rdp_kbd_remap.*/rdp_kbd_remap=0x15b=/' "$HOME/.config/remmina/remmina.pref"
      '';
    };
  };
}
