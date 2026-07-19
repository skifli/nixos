{
  lib,
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home = {
      packages = with pkgs; [
        remmina
      ];

      activation.setRemminaKeyboard = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Make it use the client keymap
        sed -i 's/^rdp_use_client_keymap.*/rdp_use_client_keymap=1/' "$HOME/.config/remmina/remmina.pref"

        # Don't passthrough Windows / mod key
        sed -i 's/^rdp_kbd_remap.*/rdp_kbd_remap=0x15b=/' "$HOME/.config/remmina/remmina.pref"
      '';
    };
  };
}
