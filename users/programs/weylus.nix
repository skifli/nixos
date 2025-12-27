{
  userVars,
  ...
}:

{
  programs.weylus = {
    enable = true;
    openFirewall = true;
    users = [ userVars.username ];
  };
}
