# Extending Modules

- [Extending Modules](#extending-modules)
  - [Add a new per-user program module](#add-a-new-per-user-program-module)
  - [Guidelines](#guidelines)

## Add a new per-user program module

1. Create a module:

```text
users/programs/<category>/<name>.nix
```

2. Add the program name into:

```text
users/<name>/variables.nix
```

## Guidelines

- Keep user choices declarative
- Read values from `userVars`
- Avoid hardcoded application names
- Keep modules reusable
