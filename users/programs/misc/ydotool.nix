{
  userVars,
  ...
}: {
  programs.ydotool.enable = true; # Whether to enable ydotoold system service and ydotool for members of programs.ydotool.group.

  users.users.${userVars.username}.extraGroups = ["ydotool"];
}
