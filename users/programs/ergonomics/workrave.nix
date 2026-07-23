{ pkgs, userVars, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      workrave = prev.workrave.overrideAttrs (oldAttrs: {
        preFixup = (oldAttrs.preFixup or "") + ''
          gappsWrapperArgs+=(
            --set GDK_BACKEND "x11"
          )
        '';
      });
    })
  ];

  home-manager = {
    users.${userVars.username} = {
      home.packages = with pkgs; [
        workrave
      ];
    };
  };
}
