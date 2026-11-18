# To-do when bringing up a NEW host

## Repo stuff before first switch

- Add host config under `hosts/<hostname>/` (copy from lyra = x86_64 desktop, fydetabduo = aarch64 tablet):
    - `configuration.nix`
    - `hardware-configuration.nix`
    - `host-packages.nix`
    - `variables.nix` - set `enabledImports`, outputs/orderedOutputs, locale/timezone, etc.
- Add user under `users/<username>/` (copy/adapt ami or fynix): `variables.nix`, `user-packages.nix`, scripts; register in `modules/core/users.nix` `enabledUsers`.
- Secrets: create any `secrets/<hostname>/*.age` and register in `secrets/secrets.nix`.
- CI: add host to `.github/workflows/nix-build.yml` matrix (`ubuntu-24.04-arm` for aarch64, `ubuntu-latest` for x86_64).

## On-device stuff

- Zen Browser -> ActivityWatch: extension auto-detects hostname from the server's `/api/0/info` (i.e., shows the SERVER's host, like pifi) and browserName defaults to "firefox". Open the extension settings and set hostname/browser to the right ones matey.
- Zen Browser -> Mozilla Sync: sign in to the same Mozilla account in Zen on each host. In Settings -> Sync, enable **History**, **Open tabs**, and **Other Workspaces**; turn the other Sync categories off. The Nix config enables Firefox Accounts, however it cannot sign in to your account for you. Then choose **Sync your sidebar across devices** and enable **Include unpinned tabs**.
- Link up `/etc/nixos` to the user's `nixos` directory.

## niri (per-display)

- Single-display (fydetab): `Mod+Ctrl+1..4` layout scripts are multi-monitor only (code gates as per orderedOutputs>1).
- Multi-display (lyra): map outputs in `orderedOutputs`, keep monitor-specific binds/scripts.

## Fydetab stuff

- When rebuilding the new config use boot NOT switch to prevent breakage!
