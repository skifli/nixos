{
  commonHostVars,
  hostVars,
  lib,
  pkgs,
  username,
  ...
}:
let
  common = import ../common/variables.nix {
    inherit
      commonHostVars
      hostVars
      lib
      pkgs
      username
      ;
  };
in
common
// rec {
  extraGroups = [
    "networkmanager"
    "wheel"
  ];

  programs = common.programs // {
    compositor = "";
    desktop-shell = "";
    display-server = "";
    login-manager = "";
    terminal = "ghostty";
    terminal-shell = "zsh";
    editor = "hx";
    launcher = "";
    idler = "";
    keyboard = "";
    visual = "hx";
    browsers = [ ];
    other = common.programs.other ++ [
      "tailscale"
      "awscli2"
      "jq"
      "yq"
      "fd"
      "ripgrep"
      "btop"
      "fzf"
      "eza"
      "git"
      "vim"
      "nix-direnv"
      "awscli2"
      "awscli2-login"
    ];
  };

  bar = {
    output = "";
  };

  shellScripts = common.shellScripts // {
    nsw = "nh os switch path:. --accept-flake-config -H ${hostVars.hostname}";
    nup = "nh os switch path:. --update --accept-flake-config -H ${hostVars.hostname}";
    ntest = "nh os test path:. --accept-flake-config -H ${hostVars.hostname}";
  };

  stylixTargetsWhitelist = [ ];

  shellScripts = common.shellScripts // {
    nsw = "nh os switch path:. --accept-flake-config -H ${hostVars.hostname}";
    nup = "nh os switch path:. --update --accept-flake-config -H ${hostVars.hostname}";
    ntest = "nh os test path:. --accept-flake-config -H ${hostVars.hostname}";
  };
}
