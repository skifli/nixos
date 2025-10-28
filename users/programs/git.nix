{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    programs.git = {
      enable = true;
      userName = userVars.git.name;
      userEmail = userVars.git.email;
      extraConfig = {
        core.editor = userVars.programs.editor;
        init.defaultBranch = "main";
      };
    };
  };
}
