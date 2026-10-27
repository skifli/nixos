{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    tailscale
    node_exporter
    prometheus
    btrfs-progs
    rsync
    rclone
    git
    vim
    htop
    btop
    jq
    yq
    fd
    ripgrep
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
  ];
}