# Continuous Integration

- [Continuous Integration](#continuous-integration)
  - [CI overview](#ci-overview)
  - [Current workflow](#current-workflow)
  - [Goals](#goals)
  - [Future improvements](#future-improvements)
  - [Example future workflow](#example-future-workflow)
  - [Suggested tooling](#suggested-tooling)
    - [Formatting](#formatting)
    - [Linting](#linting)
    - [Validation](#validation)
  - [Example local validation](#example-local-validation)

This repository includes lightweight CI checks for flake hygiene and evaluation.

## CI overview

```mermaid
flowchart TD

    A[Push or PR]
    B[GitHub Actions]
    C[Flake checks]
    D[Evaluation succeeds]
    E[CI passes]

    A --> B --> C --> D --> E
```

## Current workflow

The repository currently includes:

```text
.github/workflows/flake-checker.yml
```

using:

- Determinate Systems flake checker

## Goals

The CI pipeline aims to:

- Catch broken flake inputs
- Validate repository structure
- Prevent accidental regressions
- Ensure configurations still evaluate

## Future improvements

Potential future additions:

| Feature | Purpose |
|---|---|
| `nix flake check` | Validate flake outputs |
| Host evaluation matrix | Test all hosts |
| Dead link checker | Validate documentation |
| Formatting checks | Enforce style consistency |
| Statix | Nix linting |
| Deadnix | Detect unused code |
| Treefmt | Unified formatting |
| Cachix integration | Binary cache uploads |

## Example future workflow

```mermaid
graph LR

    A[Push]
    B[Format checks]
    C[Linting]
    D[Flake evaluation]
    E[Host builds]
    F[CI success]

    A --> B --> C --> D --> E --> F
```

## Suggested tooling

### Formatting

- `alejandra`
- `treefmt`

### Linting

- `statix`
- `deadnix`

### Validation

- `nix flake check`

## Example local validation

Run checks locally before pushing:

```bash
nix flake check
```

Linting:

```bash
statix check .
deadnix .
```

Formatting:

```bash
alejandra .
```
