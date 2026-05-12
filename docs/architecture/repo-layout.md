# Repository Layout

- [Repository Layout](#repository-layout)
  - [High-level structure](#high-level-structure)
  - [Directory responsibilities](#directory-responsibilities)

This configuration aims to:

- Keep user preferences declarative.
- Separate policy from implementation.
- Minimise hardcoded application assumptions.
- Make swapping components trivial.
- Share logic across hosts cleanly.

## High-level structure

```mermaid
graph TD

    A[flake.nix]

    A --> B[hosts]
    A --> C[modules]
    A --> D[users]
    A --> E[secrets]
    A --> F[docs]

    B --> B1[Per-host system definitions]
    C --> C1[Reusable NixOS modules]
    D --> D1[Home Manager configuration]
    E --> E1[Agenix encrypted secrets]
    F --> F1[Project documentation]
```

## Directory responsibilities

| Path                  | Purpose                      |
|-----------------------|------------------------------|
| [`hosts/`](../../hosts)     | Per-host NixOS configuration |
| [`modules/`](../../modules) | Reusable NixOS modules       |
| [`users/`](../../users)     | Home Manager configuration   |
| [`docs/`](../../docs)       | Detailed documentation       |
| [`secrets/`](../../secrets) | Encrypted Agenix secrets     |