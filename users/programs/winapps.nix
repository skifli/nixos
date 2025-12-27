# NOT UPDATED ANYMORE

{
  inputs,
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home = {
      file.".config/winapps/winapps.conf".source = ./winapps.conf;
      sessionVariables.WINAPPS_SRC_DIR = "/home/${userVars.username}/.local/bin/winapps-src"; # For local install

      packages = with pkgs; [
        inputs.winapps.packages."${pkgs.stdenv.hostPlatform.system}".winapps
        inputs.winapps.packages."${pkgs.stdenv.hostPlatform.system}".winapps-launcher # optional

        dialog
        freerdp
        libnotify
        yad # For winapps-launcher

        /*
          podman
          podman-compose
          podman-tui
        */
      ];
    };
  };

  /*
    virtualisation = {
      containers.enable = true;

      podman = {
        enable = true;
        dockerCompat = true; # For docker-compose compatibility
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    users.users.${userVars.username} = {
      extraGroups = [
      "podman"
        "kvm"
      ]; # Add 'kvm' for access to /dev/kvm
    };

    system.userActivationScripts = {
      winappsSetup = {
        text = ''
          mkdir -p $HOME/.config
          cd $HOME/.config
          if [ ! -d "winapps" ]; then
            git clone https://github.com/winapps-org/winapps/
          else
            cd winapps
            git pull
            cd ..
          fi
          podman-compose --file winapps/compose.yaml down
          rm -f $HOME/.config/freerdp/server/127.0.0.1_3389.pem
          podman-compose --file winapps/compose.yaml up
        '';
        deps = [ ];
      };
    };
  */
}
