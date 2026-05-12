# Secret File Reference

- [Secret File Reference](#secret-file-reference)
  - [Common secret files](#common-secret-files)
  - [Password hash generation](#password-hash-generation)
  - [GitHub CLI note](#github-cli-note)

## Common secret files

| File | Purpose |
| --- | --- |
| `hashedPasswordFile.age` | User password hash |
| `github-credentials.age` | Git credential store entries |
| `github-pat.age` | GitHub PAT only |
| `gh-hosts.yml.age` | Full GitHub CLI hosts file |
| `anki-keyFile.age` | AnkiWeb key |
| `anki-usernameFile.age` | AnkiWeb username/email |

## Password hash generation

```bash
mkpasswd -m sha-512
```

## GitHub CLI note

`gh` does not automatically read `~/.github-pat`.

Prefer providing:

```text
~/.config/gh/hosts.yml
```

through Agenix.
