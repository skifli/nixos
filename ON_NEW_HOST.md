# To-do when bringing up a NEW host

## Repo stuff before first switch

- Add host config under `hosts/<hostname>/` (copy from lyra = x86_64 desktop, fydetabduo = aarch64 tablet):
  - `configuration.nix`
  - `hardware-configuration.nix`
  - `host-packages.nix`
  - `variables.nix` - set `enabledImports`, outputs/orderedOutputs, locale/timezone, etc.
- Add user under `users/<username>/` (copy/adapt ami or fynix): `variables.nix`, `user-packages.nix`, scripts; register in `modules/core/users.nix` `enabledUsers`.
- Secrets: create any `secrets/<hostname>/*.age` (e.g. oracle proxy) and register in `secrets/secrets.nix`.
- CI + Cachix: add host to `.github/workflows/nix-build.yml` matrix (runner: `ubuntu-latest` x86_64, `ubuntu-24.04-arm` ARM64); push + pin `<host>-light` / `<host>-dark`.

## On-device stuff

- Zen Browser -> ActivityWatch: extension auto-detects hostname from the server's `/api/0/info` (i.e., shows the SERVER's host, like pifi) and browserName defaults to "firefox". Open the extension settings and set hostname/browser to the right ones matey.

## niri (per-display)

- Single-display (tablet): `Mod+Ctrl+1..4` layout scripts are multi-monitor only (code gates as per orderedOutputs>1).
- Multi-display (lyra): map outputs in `orderedOutputs`, keep monitor-specific binds/scripts.
