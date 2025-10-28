{ commonHostVars, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    fontDir.enable = true;
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        sansSerif = [ commonHostVars.fonts.sansSerif.name ];
        serif = [ commonHostVars.fonts.serif.name ];
        monospace = [ commonHostVars.fonts.monospace.name ];
        emoji = [ commonHostVars.fonts.emoji.name ];
      };
    };
    packages = [
      commonHostVars.fonts.sansSerif.package
      commonHostVars.fonts.serif.package
      commonHostVars.fonts.monospace.package
      commonHostVars.fonts.emoji.package
    ];
  };
}
