# nixOS - An indubitably splendiferous configuration [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Open Source Love svg2](https://badges.frapsoft.com/os/v2/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/) ![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?logo=nixos) ![Flakes](https://img.shields.io/badge/Flakes-enabled-blue) ![Wayland](https://img.shields.io/badge/Wayland-Niri-purple)

- [nixOS - An indubitably splendiferous configuration     ](#nixos---an-indubitably-splendiferous-configuration-----)
  - [(Some) available program options](#some-available-program-options)
  - [Screenshots](#screenshots)

![Example image of my configuration in use!](assets/cover.png)

> [!WARNING]
> The image above is _very_ out of date. I'll update it when I can, but a lot of changes have occurred since that picture was taken (whoops!)

A modular NixOS + Home Manager configuration. It is easily extensible but comes with the following opinionated default setup:

- A Wayland display server running the **niri** scrollable-tiling compositor, with auto-login via **greetd**.
- **Wayle** as the unified desktop shell (handling bar, notifications, OSD, and media status).
- **Vicinae** as the app launcher (lovely UI by the way).
- **Ghostty** with **Zsh**, **Starship** prompt, and **Atuin** history.
- **Helix** as a TUI editor and **Zed** as a GUI editor.
- **Yazi** as a TUI and **Dolphin** as a GUI file explorer.
- An extensively declarative **Zen Browser** configuration.
- Solar-calculated automatic light/dark theme switching using **Stylix** and **sunwait**.
- Secret encryption via **Agenix**.
- And much, much more...

> [!NOTE]
> The main host in this repository is `lyra`.

## (Some) available program options

More are available (that I've added myself to the code but not the below concise list), but these are the main ones. And it is, of course, trivial to add your own.

> [!IMPORTANT]
> Values are the file name without `.nix`.

<details>
<summary>Desktop session</summary>

| Key in `userVars.programs` | Available values | Upstream                                          |
|----------------------------|------------------|---------------------------------------------------|
| `compositor`               | `niri`           | [niri](https://github.com/YaLTeR/niri)            |
| `desktop-shell`            | `wayle`          | [Wayle](https://github.com/wayle-shell/wayle)     |
| `display-server`           | `wayland`        | [Wayland](https://wayland.freedesktop.org/)       |
| `idler`                    | `swayidle`       | [swayidle](https://github.com/swaywm/swayidle)    |
| `keyboard`                 | `kanata`         | [Kanata](https://github.com/jtroo/kanata)         |
| `killer`                   | `earlyoom`       | [earlyoom](https://github.com/rfjakob/earlyoom)   |
| `launcher`                 | `vicinae`        | [Vicinae](https://vicinae.com/)                   |
| `login-manager`            | `greetd`         | [greetd](https://github.com/kennylevinsen/greetd) |
| `nightlight`               | `sunsetr`        | [sunsetr](https://github.com/tw4144/sunsetr)      |

</details>

<details>
<summary>Apps and tools</summary>

| Key in `userVars.programs` | Available values        | Upstream                                                                            |
|----------------------------|-------------------------|-------------------------------------------------------------------------------------|
| `browsers` (list)          | `zen-beta`, `browseros` | [Zen Browser](https://zen-browser.app/), [BrowserOS](https://browseros.com/)        |
| `editor`                   | `hx`                    | [Helix](https://helix-editor.com/)                                                  |
| `ergonomics`               | `safeeyes`              | [Safe Eyes](https://slgobinath.github.io/SafeEyes/)                                 |
| `explorer-gui`             | `dolphin`, `nemo`       | [Dolphin](https://apps.kde.org/dolphin/), [Nemo](https://github.com/linuxmint/nemo) |
| `explorer-tui`             | `yazi`                  | [Yazi](https://yazi-rs.github.io/)                                                  |
| `network-mounts`           | `nfs`                   | NFS remote mount automation                                                         |
| `pager`                    | `ov`                    | [ov](https://noborus.github.io/ov/)                                                 |
| `partition-manager`        | `kde`                   | [KDE Partition Manager](https://apps.kde.org/partitionmanager/)                     |
| `remote-desktop`           | `freerdp`, `remmina`    | [FreeRDP](https://www.freerdp.com/), [Remmina](https://remmina.org/)                |
| `screen-recorder`          | `gpu-screen-recorder`   | [GPU Screen Recorder](https://git.dec05eba.com/gpu-screen-recorder/about/)          |
| `system-monitor`           | `missioncenter`         | [Mission Center](https://missioncenter.io/)                                         |
| `vpn`                      | `tailscale`             | [Tailscale](https://tailscale.com/)                                                 |

</details>

<details>
<summary>Shell and prompt</summary>

| Key in `userVars.programs` | Available values | Upstream                         |
|----------------------------|------------------|----------------------------------|
| `terminal`                 | `ghostty`        | [Ghostty](https://ghostty.org/)  |
| `terminal-shell`           | `zsh`            | [Zsh](https://www.zsh.org/)      |
| `prompt`                   | `starship`       | [Starship](https://starship.rs/) |
| `visual`                   | `zeditor`        | [Zed](https://zeditor.dev/)      |

</details>

<details>
<summary>Extra modules (under <code>programs.other</code>)</summary>

These modules are under `users/programs/misc/` and can be enabled by adding their name to the `programs.other` list in `variables.nix`:

* `affinity` - Serif Affinity suite.
* `anki` - Spaced repetition flashcard software with custom add-ons & FSRS.
* `atuin` - Shell history sync and daemon search.
* `aw` - ActivityWatch automated time tracking & watchers.
* `kde-connect` - Device synchronization & clipboard integration.
* `nix-direnv` - Fast per-directory Nix devenvs.
* `nix-index-database` - Fast binary search & comma (`nix-index`) integration.
* `nix-your-shell` - Consistent subshell environment preservation.
* `opentabletdriver` - Open source graphics tablet driver & daemon.
* `steam` - Steam gaming platform with Proton-GE & GameMode support.
* `styles` - System-wide base16 theming, GTK/Qt synchronization, & daemon for the auto theme switching!
* `typst` - Fast markup-based typesetting system.
* `ydotool` - Wayland-compatible command-line automation for programmatic input.

</details>

## Screenshots

TODO: Add screenshots or desktop previews here later :).