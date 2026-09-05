# File: ./users/programs/remote-desktop/freerdp.nix
{
  hostVars,
  pkgs,
  userVars,
  ...
}:
let
  rdpLayoutMap = {
    "gb" = "0x00000809";
    "uk" = "0x00000809";
    "us" = "0x00000409";
    "de" = "0x00000407";
    "fr" = "0x0000040c";
  };

  kbdCode = rdpLayoutMap.${hostVars.keyboardLayout} or "0x00000809";
in
{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      freerdp
      tigervnc
    ];

    home.sessionVariables = {
      RDP_KBD = kbdCode;
    };
  };
}
