{userVars, ...}: {
  home-manager.users.${userVars.username} = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      settings = {};

      keymap = {
        mgr.prepend_keymap = [
          # 'c u' -> Plain text file:// URL
          {
            on = ["c" "u"];
            run = "shell 'copyl.sh --text %s'";
            desc = "Copy file:// URL";
          }

          # 'c l' -> Wayland URI list (pasteable attachment)
          {
            on = ["c" "l"];
            run = "shell 'copyl.sh %s'";
            desc = "Copy file:// URI list";
          }
        ];
      };
    };
  };
}
