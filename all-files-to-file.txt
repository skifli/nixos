find . \
  -type f \
  -iname "*.nix" \
  ! -iname "hardware-configuration.nix" \
  -exec sh -c 'for f; do echo ===== $f ===== ; cat "$f" ; echo; done' _ {} + > output.txt
