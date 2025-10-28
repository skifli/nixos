{ pkgs, ... }:

{
  # Specify which packages to install on a system level
  environment.systemPackages = with pkgs; [
    nixd # Nix language server
    fastfetch # Neofetch C alternative
  ];
}
