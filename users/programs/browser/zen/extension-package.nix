{ pkgs }:

{
  source,
  manifest,
  policy ? null,
  assets ? { },
}:
let
  inherit (pkgs) lib;
  hostPatterns =
    if policy == null then [ ] else map (site: "*://*.${site.domain}/*") policy.blockedSites;
  packagedManifest =
    if policy == null then
      manifest
    else if manifest.manifest_version == 2 then
      manifest
      // {
        permissions = (manifest.permissions or [ ]) ++ hostPatterns;
      }
    else
      manifest
      // {
        host_permissions = (manifest.host_permissions or [ ]) ++ hostPatterns;
      };
  manifestFile = pkgs.writeText "${lib.toLower (lib.replaceStrings [ " " ] [ "-" ] manifest.name)}-manifest.json" (
    builtins.toJSON packagedManifest
  );
  policyFile = lib.optionalString (policy != null) (
    toString (
      pkgs.writeText "${lib.toLower (lib.replaceStrings [ " " ] [ "-" ] manifest.name)}-policy.json" (
        builtins.toJSON policy
      )
    )
  );
  assetInstallCommands = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (destination: asset: ''
      install -D ${asset} "xpi/${destination}"
    '') assets
  );
  xpi =
    pkgs.runCommand
      "${lib.toLower (lib.replaceStrings [ " " ] [ "-" ] manifest.name)}-${manifest.version}.xpi"
      {
        nativeBuildInputs = [ pkgs.zip ];
      }
      ''
        mkdir -p xpi
        cp -R ${source}/. xpi/
        chmod -R u+w xpi
        cp ${manifestFile} xpi/manifest.json
        ${lib.optionalString (policy != null) "cp ${policyFile} xpi/policy.json"}
        ${assetInstallCommands}
        cd xpi
        zip -X -q -r "$out" ./*
      '';
in
{
  inherit xpi;
  id = manifest.browser_specific_settings.gecko.id;
  settings = {
    installation_mode = "force_installed";
    private_browsing = true;
    install_url = "file://${xpi}";
  };
}
