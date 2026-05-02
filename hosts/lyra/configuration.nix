{
  hostname,
  ...
}:
{
  _module.args = { inherit hostname; };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-38.8.4" # error: Package ‘electron-38.8.4’ in /nix/store/fm3z9r7r90yh8l7ai6cn6gsrp6h27ira-source/pkgs/development/tools/electron/binary/generic.nix:43 is marked as insecure, refusing to evaluate. … while evaluating definitions from `/nix/store/ldb7cdc0xb3hifpyywkiy905b5ywa1q2-source/modules/misc/fontconfig.nix':
  ];

  imports = [
    ../common/default.nix
  ];
}
