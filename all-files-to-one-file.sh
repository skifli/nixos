find . -type f \
  \( -iname "*.nix"  -o \
     -iname "*.lock" -o \
     -iname "*.sh"   -o \
     -iname "*.md"   -o \
     -iname "*.txt"  -o \
     -iname "*.yml"  -o \
     -iname "*.conf" \) \
  ! -name "output.txt" \
  ! -iname "hardware-configuration.nix" \
  -exec sh -c 'for f; do echo "===== $f ====="; cat "$f"; echo; done' _ {} + > output.txt
