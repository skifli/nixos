{
  pkgs,
  userVars,
  ...
}: {
  home-manager.users.${userVars.username} = {
    home.packages = with pkgs; [
      (safeeyes.overridePythonAttrs (oldAttrs: {
        # The following are for some reason defined in the https://github.com/NixOS/nixpkgs/blob/b3fe9581c9061c749abef42b6d4ee7b7c05c33fa/pkgs/by-name/sa/safeeyes/package.nix#L52 file as optional-dependencies but not actual dependencies, no idea why as optional-dependencies is not as far as I am aware reference further (at least in that file), but anyway. Maybe I don't understand how optional-dependencies should work
        dependencies = (oldAttrs.dependencies or []) ++ [
          python3Packages.croniter # Needed for Health Statistics
          python3Packages.pywayland # Needed for Smart Pause
        ];
      }))
    ];
  };
}
