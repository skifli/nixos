{
  inputs,
  pkgs,
  userVars,
  ...
}:

{
  home-manager = {
    sharedModules = [ inputs.lan-mouse.homeManagerModules.default ];

    users.${userVars.username} = {
      home.packages = with pkgs; [
        libei
      ];

      programs.lan-mouse = {
        enable = true;
        systemd = true;
        package = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.lan-mouse;

        # Optional configuration in nix syntax, see config.toml for available options
        settings = {
          clients = [
            {
              position = "bottom";
              hostname = "fyde";
              activate_on_startup = true;
            }
          ];
        };
      };
    };
  };

  networking.firewall = rec {
    allowedUDPPorts = [
      4242
    ];

    allowedTCPPorts = allowedUDPPorts;
  };
}
