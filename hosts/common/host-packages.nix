{ pkgs, ... }:

{
  # Specify which packages to install on a system level
  environment.systemPackages = with pkgs; [
    nix-index # Quickly locate the package providing a certain file
    nixfmt-rfc-style
    nixd # Nix language server
  ];
}
