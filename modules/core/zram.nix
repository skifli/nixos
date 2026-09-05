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
