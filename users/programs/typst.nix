{
  pkgs,
  userVars,
  ...
}:

{
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      typst
      typst-live
      typstwriter
      typstyle

      # Extra
      typstPackages.abbr
      typstPackages.algo
      typstPackages.boxr
      typstPackages.cetz
      typstPackages.cheq
      typstPackages.cuti
      typstPackages.down
      typstPackages.flow
      typstPackages.hane
      typstPackages.jogs
      typstPackages.mino
      typstPackages.nth
      typstPackages.nup
      typstPackages.tada
      typstPackages.tblr
      typstPackages.tidy
      typstPackages.treet
      typstPackages.tutor
      typstPackages.umbra
      typstPackages.unify
      typstPackages.wavy
      typstPackages.weave
      typstPackages.yats
      typstPackages.zero
    ];
  };
}
