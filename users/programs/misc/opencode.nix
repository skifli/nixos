{
  pkgs,
  pkgsUnstable,
  userVars,
  ...
}:
{
  home-manager = {
    users.${userVars.username} = {
      home.packages = with pkgs; [
        (pkgsUnstable.opencode)

        # Required for OpenCode
        nodejs_22
        bun

        # Required by opencode-direnv
        direnv
        nix-direnv

        # Required by opentmux
        tmux

        # Required by opencode-notify (desktop alerts)
        libnotify

        # Opencode-snip
        snip
      ];

      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        plugin = [
          "@simonwjackson/opencode-direnv"
          "@tarquinen/opencode-dcp@latest"
          "opencode-background-agents"
          "opencode-handoff"
          "opentmux"
          "opencode-adaptive-thinking"
          "opencode-notify"
          "opencode-update-notifier"
          "opencode-snip@latest"
          "@knikolov/opencode-plugin-simple-memory"
        ];
      };
    };
  };

  programs = {
    direnv.enable = true;
    nix-ld.enable = true;
  };
}
