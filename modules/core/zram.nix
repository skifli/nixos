_: {
  zramSwap = {
    enable = true;
    memoryPercent = 125;
    # Compression algorithm.
    # lzo has good compression, but is slow.
    # lz4 has bad compression, but is fast.
    # zstd is both good compression and fast, but requires newer kernel.
    # You can check what other algorithms are supported by your zram device with cat /sys/class/block/zram*/comp_algorithm
    algorithm = "zstd";
  };

  boot = {
    kernel.sysctl = {
      # Tell kernel to heavily prefer ZRAM over filesystem page flushing
      "vm.swappiness" = 180;
    };
  };
}
