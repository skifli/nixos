{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Raspberry Pi essentials
    rpi-eeprom
    vcgencmd
    i2c-tools
    lm-sensors
    smartmontools
    nvme-cli
    hdparm

    # Network/VPN
    tailscale
    networkmanager
    nmcli
    wpa_supplicant

    # Filesystem/backup
    borgbackup
    btrfs-progs
    rsync
    rclone

    # Monitoring
    node_exporter
    prometheus

    # Development
    git
    vim
    htop
    btop
    jq
    yq
    fd
    ripgrep

    # Fonts
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
  ];
}
