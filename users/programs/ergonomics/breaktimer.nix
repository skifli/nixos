{
  pkgsUnstable,
  userVars,
  ...
}: {
  home-manager = {
		sharedModules = [./wine-sni-bridge/nix/module.nix];

		users.${userVars.username} = {
			services.wine-sni-bridge.enable = true;
		};
  };
}
