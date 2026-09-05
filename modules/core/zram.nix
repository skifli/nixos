{ pkgs, ... }: {
  zramSwap = {
    enable = true;
    memoryPercent = 125;
    priority = 100;

    # Compression algorithm.
    # lzo has good compression, but is slow.
    # lz4 has bad compression, but is fast.
    # zstd is both good compression and fast, but requires newer kernel.
    # You can check what other algorithms are supported by your zram device with cat /sys/class/block/zram*/comp_algorithm
    algorithm = "zstd";
  };

  # Drain swap early during shutdown so zram deactivation doesn't hang.
  # With swappiness=180, zram holds a lot of compressed pages that can take
  # minutes to decompress if swapoff runs late in the shutdown list of stuff todo.
  systemd.services.early-swapoff = {
    description = "Disable all swap before services stop";
    wantedBy = [
      "shutdown.target"
      "reboot.target"
      "halt.target"
      "kexec.target"
    ];
    before = [
      "shutdown.target"
      "reboot.target"
      "halt.target"
      "kexec.target"
    ];
    unitConfig = {
      DefaultDependencies = false;
      Conflicts = "shutdown.target";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl stop '*.swap'";
      TimeoutStartSec = "30s";
    };
  };

  boot = {
    kernelParams = [
      "zswap.enabled=0" # Prevent CPU wasting cycles compressing before ZRAM
    ];

    kernel.sysctl = {
      # Tell kernel to heavily prefer ZRAM over filesystem page flushing
      "vm.swappiness" = 180;

      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0; # Reads 1 page at a time (0 disk readahead latency overhead)
    };
  };
}
