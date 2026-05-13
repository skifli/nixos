# Compatibility shim for zen-beta to zen.nix
#
# Reason:
# - The upstream zen-browser-flake names the binary "zen-beta", so our config
#   references it as "zen-beta" (per the pattern of using binary names).
# - However, the actual configuration file is now named zen.nix for clarity,
#   as some other sites (including the official documentation :0) link to my
#   zen.nix file, which if we rename to zen-beta.nix wouldn't exist.
# - This file simply passes through to the real implementation in zen.nix,
#   ensuring compatibility with config that references "zen-beta" while
#   keeping the implementation in the more discoverable zen.nix file.
#
# To update Zen Browser config: edit zen.nix, not this file.
args: (import ./zen.nix args)
