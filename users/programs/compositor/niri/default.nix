attrs:
let
  settings = import ./settings.nix attrs;
in
{
  enable = true;

  systemd.variables = [
    "--all"
  ];

  inherit settings;
}
