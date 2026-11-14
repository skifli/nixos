{ hostname, ... }: {
  _module.args = { inherit hostname; };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-38.8.4" # error: Package 'electron-38.8.4' in /nix/store/fm3z9r7r90yh8l7ai6cn6gsrp6h27ira-source/pkgs/development/tools/electron/binary/generic.nix:43 is marked as insecure, refusing to evaluate. … while evaluating definitions from `/nix/store/ldb7cdc0xb3hifpyywkiy905b5ywa1q2-source/modules/misc/fontconfig.nix':
  ];

  imports = [
    ../common/default.nix
  ];

  networking = {
    # Pin Wi-Fi power save off. The driver default is already off, but this makes it
    # survive kernel changes / flake updates.
    networkmanager.wifi.powersave = false;
  };

  # iw reg get reported "country 00" (no regulatory domain), so 5 GHz TX power and DFS
  # handling were unbounded/unset. The AP sits on DFS channel 108. NixOS has no
  # regulatoryDomain option in this nixpkgs, so set the cfg80211 default directly.
  # (wireless-regdb itself is already installed via hardware.wirelessRegulatoryDatabase.)
  boot.kernelParams = [
    "cfg80211.ieee80211_regdom=GB"
  ];

  # Complements the NetworkManager setting above.
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr"; # Better throughput on lossy Wi-Fi
    "net.core.default_qdisc" = "fq"; # Pairs with BBR
    "net.ipv4.tcp_slow_start_after_idle" = 0; # Don't reset cwnd after idle
  };
}
