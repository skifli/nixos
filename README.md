<<<<<<< HEAD
## First-time install
1. Run `kbuildsycoca6` (populates the binary cache of data for KDE - so default apps iirc in Dolphin).

## How to setup in ~/nixos

### 1. Create a directory for your config

```bash
mkdir -p ~/nixos
```

### 2. Move existing config out of `/etc/nixos`

```bash
sudo mv /etc/nixos/* ~/nixos/
```

### 3. Remove the old `/etc/nixos` directory

```bash
sudo rmdir /etc/nixos
```

### 4. Create a symlink back to your home config

```bash
sudo ln -s /home/$(whoami)/nixos /etc/nixos
```

### 5. Rebuild to confirm everything works

```bash
sudo nixos-rebuild switch
```
=======
1. Run `kbuildsycoca6`.
>>>>>>> 98f10f82d6385071afd666d63032ffb49ab0e20c
