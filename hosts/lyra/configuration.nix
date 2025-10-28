{
  hostname,
  ...
}:
{
  _module.args = { inherit hostname; };

  imports = [
    ../common/default.nix
  ];
}
