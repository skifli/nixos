{userVars, ...}: {
  # Enable Kanata system service
  services.kanata = {
    enable = true;
    keyboards = userVars.kanata.keyboards;
  };

  hardware.uinput.enable = true;
  users.groups.uinput.members = [userVars.username];
  users.groups.input.members = [userVars.username];
}
