{
  commonHostVars,
  hostVars,
  hostname,
  lib,
  pkgs,
  usersVars,
  ...
}:
let
  projectDirectory = "/var/lib/open-terminal-projects";
  credentialDirectory = "/var/lib/open-terminal-git-credentials";
  device =
    {
      lyra = {
        imageDigest = "sha256:9c7f03281e8f83ff708ed26a10394631e91d5568910cb2a6c92d91857e219371";
      };
      fydetabduo = {
        imageDigest = "sha256:cbd5340508cfd08c5940621e390bcdae0aee49c23ae9a11754e5e0349e211b66";
      };
    }
    .${hostname} or null;
  terminalUsername = builtins.head hostVars.enabledUsers;
  gitIdentity = usersVars.${terminalUsername}.git;
  gitConfigDirectory = pkgs.writeTextDir "gitconfig/open-terminal.conf" ''
    [user]
      name = ${gitIdentity.name}
      email = ${gitIdentity.email}
  '';
  nixosSource =
    {
      lyra = "/home/ami/nixos";
      fydetabduo = "/home/fynix/nixos";
    }
    .${hostname} or null;
  tailscaleAddress = commonHostVars.tailscaleDevices.${hostname}.address;
  terminalContext = ''
    This Open Terminal session runs in a container connected to ${hostname}. Its shell hostname describes the container, not necessarily the physical device. Verify the target before host-specific work.
    ${
      if hostname == "lyra" then
        "Lyra is the desktop workstation. /projects/nixos is the live local checkout at /home/ami/nixos for the public skifli/nixos repository."
      else
        "FydeTab Duo is the tablet. /projects/nixos is the live local checkout at /home/fynix/nixos for the public skifli/nixos repository; its hardware base comes from NixOnFyde/fyde-nix."
    }
    Inspect the target directory and git status before editing, and preserve unrelated changes. Never read or print secret files, keys, tokens, or passwords. Do not commit, push, rebuild, restart, or deploy unless the user explicitly asks.
  '';
  githubSshConfig = pkgs.writeText "open-terminal-github-ssh-config" ''
    Host github-sernix
      HostName github.com
      User git
      IdentitiesOnly yes
      IdentityFile /run/secrets/github/sernix
      HostKeyAlias github.com
      UserKnownHostsFile /run/secrets/github/known_hosts
      GlobalKnownHostsFile /dev/null
      StrictHostKeyChecking yes
      BatchMode yes
    Host github-oracle-vps
      HostName github.com
      User git
      IdentitiesOnly yes
      IdentityFile /run/secrets/github/oracle-vps
      HostKeyAlias github.com
      UserKnownHostsFile /run/secrets/github/known_hosts
      GlobalKnownHostsFile /dev/null
      StrictHostKeyChecking yes
      BatchMode yes
    Host github-zen-profile-default
      HostName github.com
      User git
      IdentitiesOnly yes
      IdentityFile /run/secrets/github/zen-profile-default
      HostKeyAlias github.com
      UserKnownHostsFile /run/secrets/github/known_hosts
      GlobalKnownHostsFile /dev/null
      StrictHostKeyChecking yes
      BatchMode yes
  '';
  githubKnownHosts = pkgs.writeText "open-terminal-github-known-hosts" ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';
  prepareGitCredentials = pkgs.writeShellScript "prepare-open-terminal-git-credentials" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/install -d -o 1000 -g 1000 -m 0700 ${credentialDirectory}
    for key in sernix oracle-vps zen-profile-default; do
      file=${credentialDirectory}/$key
      if [ ! -s "$file" ]; then
        echo "Required read-only GitHub deploy key is missing: $file" >&2
        exit 1
      fi
      ${pkgs.coreutils}/bin/chown 1000:1000 "$file"
      ${pkgs.coreutils}/bin/chmod 0400 "$file"
    done
    ${pkgs.coreutils}/bin/install -o 1000 -g 1000 -m 0600 ${githubSshConfig} ${credentialDirectory}/config
    ${pkgs.coreutils}/bin/install -o 1000 -g 1000 -m 0600 ${githubKnownHosts} ${credentialDirectory}/known_hosts
  '';
  prepareWorkspace = pkgs.writeShellScript "prepare-open-terminal-workspace" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/install -d -o 1000 -g 1000 -m 0750 ${projectDirectory}
  '';
  prepareOpenTerminal = pkgs.writeShellScript "prepare-open-terminal" ''
    set -euo pipefail
    ${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/open-terminal
    if ! ${pkgs.coreutils}/bin/test -s /var/lib/open-terminal/api-key; then
      umask 077
      ${pkgs.openssl}/bin/openssl rand -hex 32 > /var/lib/open-terminal/api-key
    fi
    ${pkgs.coreutils}/bin/chmod 0600 /var/lib/open-terminal/api-key
    printf 'OPEN_TERMINAL_API_KEY=%s\n' "$(${pkgs.coreutils}/bin/cat /var/lib/open-terminal/api-key)" > /var/lib/open-terminal/open-terminal.env
    ${pkgs.coreutils}/bin/chmod 0600 /var/lib/open-terminal/open-terminal.env
  '';
  waitForTailscale = pkgs.writeShellScript "wait-for-open-terminal-tailscale" ''
    set -euo pipefail
    for attempt in $(${pkgs.coreutils}/bin/seq 1 120); do
      if ${pkgs.tailscale}/bin/tailscale ip -4 2>/dev/null | ${pkgs.gnugrep}/bin/grep -Fxq ${tailscaleAddress}; then
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done
    echo "Tailscale address ${tailscaleAddress} did not become available" >&2
    exit 1
  '';
in
{
  config = lib.mkIf (device != null) {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers.open-terminal = {
      image = "ghcr.io/open-webui/open-terminal:0.18.0@${device.imageDigest}";
      ports = [ "${tailscaleAddress}:8000:8000" ];
      environment = {
        OPEN_TERMINAL_CORS_ALLOWED_ORIGINS = "https://oracle-nix.tail1b960.ts.net:9443";
        GIT_CONFIG_SYSTEM = "/run/open-terminal-gitconfig/open-terminal.conf";
        GIT_CONFIG_COUNT = "1";
        GIT_CONFIG_KEY_0 = "credential.helper";
        GIT_CONFIG_VALUE_0 = "";
        GIT_SSH_COMMAND = "ssh -F /run/secrets/github/config";
        GIT_TERMINAL_PROMPT = "1";
        OPEN_TERMINAL_START_DIR = "/projects";
        OPEN_TERMINAL_FILE_BROWSER_ROOT = "/projects";
        OPEN_TERMINAL_FILE_BROWSER = "true";
        OPEN_TERMINAL_COMMAND_TIMEOUT = "5";
        OPEN_TERMINAL_INFO = terminalContext;
      };
      environmentFiles = [ "/var/lib/open-terminal/open-terminal.env" ];
      volumes = [
        "open-terminal-data:/home/user"
        "${projectDirectory}:/projects"
        "${nixosSource}:/projects/nixos"
        "${credentialDirectory}:/run/secrets/github:ro"
        "${gitConfigDirectory}/gitconfig:/run/open-terminal-gitconfig:ro"
      ];
      extraOptions = [
        "--init"
        "--security-opt=no-new-privileges:true"
      ]
      ++ lib.optionals (hostname == "fydetabduo") [
        # Fyde's kernel has no POSIX mqueue support. Replace Podman's default
        # /dev/mqueue mount with an inert device while keeping IPC private.
        "--mount=type=bind,source=/dev/null,target=/dev/mqueue"
      ];
    };

    systemd.services.podman-open-terminal = {
      requires = [ "tailscaled.service" ];
      after = [ "tailscaled.service" ];
      serviceConfig.ExecStartPre = lib.mkBefore [
        "+${prepareOpenTerminal}"
        "+${prepareGitCredentials}"
        "+${prepareWorkspace}"
        "+${waitForTailscale}"
      ];
    };
  };
}
