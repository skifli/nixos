# Rebuild Workflows

- [Rebuild Workflows](#rebuild-workflows)
  - [Rebuild flow](#rebuild-flow)
  - [Common commands](#common-commands)
  - [Standard rebuild](#standard-rebuild)
  - [Dry-run rebuild](#dry-run-rebuild)
  - [Test rebuild](#test-rebuild)
  - [Updating flake inputs](#updating-flake-inputs)
  - [Diffing generations](#diffing-generations)
  - [Automatic activation steps](#automatic-activation-steps)
    - [KDE cache refresh](#kde-cache-refresh)
    - [Hosts blocklist refresh](#hosts-blocklist-refresh)
  - [Rollback](#rollback)

This repository uses `nh` wrappers and flake-based rebuild workflows.

## Rebuild flow

```mermaid
flowchart LR

    A[Edit configuration]
    B[nh os switch]
    C[Nix evaluates flake]
    D[System builds]
    E[Activation scripts run]
    F[New generation created]

    A --> B --> C --> D --> E --> F
```

## Common commands

| Alias | Command | Purpose |
|---|---|---|
| `nfu` | `nix flake update` | Update flake inputs |
| `nhsw` | `nh os switch . --accept-flake-config -H` | Apply system configuration |
| `nhtest` | `nh os test . --accept-flake-config -H` | Temporary test rebuild |
| `nhdry` | `nh os switch . --dry --accept-flake-config -H` | Dry-run evaluation |
| `nhask` | `nh os switch . --ask --accept-flake-config -H` | Interactive confirmation |
| `nhdiff` | build + diff with `nvd` | Compare generations |
| `nup` | shorthand for `nh os switch . -H` | Fast rebuild alias |

## Standard rebuild

```bash
nh os switch . --accept-flake-config -H
```

or:

```bash
nup
```

## Dry-run rebuild

Useful for checking evaluation without applying changes.

```bash
nh os switch . --dry --accept-flake-config -H
```

## Test rebuild

Builds and activates the configuration temporarily.

```bash
nh os test . --accept-flake-config -H
```

The configuration will not persist across reboot.

## Updating flake inputs

```bash
nix flake update
```

or:

```bash
nfu
```

## Diffing generations

```bash
nhdiff
```

This builds the current configuration and compares it against the active generation using `nvd`.

## Automatic activation steps

Some actions occur automatically during rebuilds.

### KDE cache refresh

```text
kbuildsycoca6
```

is automatically triggered via activation script.

### Hosts blocklist refresh

```text
hblock
```

is refreshed weekly through a systemd timer.

## Rollback

Previous generations remain available through the bootloader.

Temporary rollback:

```bash
sudo nixos-rebuild switch --rollback
```
