{
  lib,
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      # Packages for zsh plugins
      chroma
      eza
      ripgrep # "completion is already included when installed via package managers"
      zoxide
    ];

    programs.zsh = {
      enable = true;

      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };

      history.size = 100000;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "colored-man-pages"
          "colorize"
          "copyfile"
          "copypath"
          "dirhistory"
          "dotenv"
          "extract"
          "eza"
          "git"
          "history-substring-search"
          "safe-paste"
          "sudo"
          "zoxide"
        ]
        ++ lib.optional (userVars.programs.prompt == "starship") "starship";
      };
    };
  };

  users.users.${userVars.username}.shell = pkgs.zsh;
}
