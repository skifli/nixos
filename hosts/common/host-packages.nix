{ pkgs, ... }:

{
  # Specify which packages to install on a system level
  environment.systemPackages = with pkgs; [
    deadnix # Find dead nix code
    fastfetch # Neofetch C alternative

    nix-index # Quickly locate the package providing a certain file
    nixfmt-rfc-style
    nixd # Nix language server

    coreutils # Some Unix CLI utilities
  ];
}
