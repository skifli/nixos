#!/usr/bin/env python3
"""Open a reviewable update for stable-release Anki add-ons pinned in anki.nix."""

from __future__ import annotations

import io
import json
import os
import re
import subprocess
import tarfile
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path, PurePosixPath


ROOT = Path(__file__).resolve().parents[2]
ANKI_NIX = ROOT / "users/programs/misc/anki.nix"
BLOCK_RE = re.compile(
    r"(?ms)^  (?P<name>[A-Za-z0-9_-]+) = pkgs\.anki-utils\.buildAnkiAddon "
    r"\(finalAttrs: \{\n(?P<body>.*?)^  \}\);"
)
VERSION_RE = re.compile(r'(?m)^([ \t]*version = ")([^"]+)(";)')
OWNER_RE = re.compile(r'(?m)^\s*owner = "([^"]+)";')
REPO_RE = re.compile(r'(?m)^\s*repo = "([^"]+)";')
HASH_RE = re.compile(r'(?m)^([ \t]*hash = ")[^"]+(";)')
SOURCE_ROOT_RE = re.compile(r'sourceRoot = "\$\{finalAttrs\.src\.name\}([^"]*)";')
STABLE_TAG_RE = re.compile(r"^v?\d+\.\d+(?:\.\d+){0,2}$")


class GitHub:
    def __init__(self) -> None:
        self.token = os.environ.get("GITHUB_TOKEN", "")

    def request(self, url: str) -> bytes:
        headers = {"User-Agent": "nixos-anki-addon-updater", "Accept": "application/vnd.github+json"}
        if self.token:
            headers["Authorization"] = f"Bearer {self.token}"
        request = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(request, timeout=60) as response:
            return response.read()

    def latest_release(self, owner: str, repo: str) -> dict | None:
        url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
        try:
            return json.loads(self.request(url))
        except urllib.error.HTTPError as error:
            if error.code == 404:
                return None
            raise

    def config_defaults(self, owner: str, repo: str, tag: str, source_root: str) -> dict | None:
        escaped_tag = urllib.parse.quote(tag, safe="")
        url = f"https://github.com/{owner}/{repo}/archive/refs/tags/{escaped_tag}.tar.gz"
        archive = self.request(url)
        wanted = PurePosixPath(source_root.lstrip("/")) / "config.json"
        with tarfile.open(fileobj=io.BytesIO(archive), mode="r:gz") as tar:
            for member in tar.getmembers():
                if not member.isfile():
                    continue
                parts = PurePosixPath(member.name).parts
                relative = PurePosixPath(*parts[1:]) if len(parts) > 1 else PurePosixPath()
                if relative != wanted:
                    continue
                stream = tar.extractfile(member)
                if stream is None:
                    return None
                value = json.loads(stream.read())
                return value if isinstance(value, dict) else None
        return None


def prefetch_hash(owner: str, repo: str, tag: str) -> str:
    escaped_tag = urllib.parse.quote(tag, safe="")
    url = f"https://github.com/{owner}/{repo}/archive/refs/tags/{escaped_tag}.tar.gz"
    fetched = subprocess.run(
        ["nix-prefetch-url", "--unpack", "--type", "sha256", url],
        check=True,
        capture_output=True,
        text=True,
    )
    base32 = next(
        (line.strip() for line in fetched.stdout.splitlines() if re.fullmatch(r"[0-9a-df-np-sv-z]{52}", line.strip())),
        None,
    )
    if base32 is None:
        raise RuntimeError(f"Could not read the Nix hash for {owner}/{repo}@{tag}")
    converted = subprocess.run(
        ["nix", "hash", "to-sri", "--type", "sha256", base32],
        check=True,
        capture_output=True,
        text=True,
    )
    return converted.stdout.strip()


def config_change_summary(old: dict | None, new: dict | None) -> list[str]:
    if old is None and new is None:
        return ["No root config.json was found in either release."]
    if old is None:
        return ["A root config.json was added upstream."]
    if new is None:
        return ["The root config.json was removed upstream."]

    lines: list[str] = []
    old_keys, new_keys = set(old), set(new)
    added = sorted(new_keys - old_keys)
    removed = sorted(old_keys - new_keys)
    changed = sorted(key for key in old_keys & new_keys if old[key] != new[key])
    if added:
        lines.append("Added defaults: " + ", ".join(f"`{key}`" for key in added))
    if removed:
        lines.append("Removed defaults: " + ", ".join(f"`{key}`" for key in removed))
    if changed:
        lines.append("Changed defaults: " + ", ".join(f"`{key}`" for key in changed))
    return lines or ["No default config keys or values changed."]


def main() -> None:
    github = GitHub()
    original = ANKI_NIX.read_text()
    output = original
    updates: list[dict] = []
    skipped: list[str] = []

    for block in BLOCK_RE.finditer(original):
        name, body = block.group("name"), block.group("body")
        version_match = VERSION_RE.search(body)
        owner_match, repo_match = OWNER_RE.search(body), REPO_RE.search(body)
        hash_match = HASH_RE.search(body)
        if not all((version_match, owner_match, repo_match, hash_match)):
            continue

        current = version_match.group(2)
        if not STABLE_TAG_RE.fullmatch(current):
            skipped.append(f"`{name}` is pinned to a commit (`{current}`); release monitoring skips commit pins.")
            continue
        if "fetchSubmodules = true;" in body:
            skipped.append(f"`{name}` fetches Git submodules; automatic hash updates are skipped for safety.")
            continue

        owner, repo = owner_match.group(1), repo_match.group(1)
        release = github.latest_release(owner, repo)
        if release is None:
            skipped.append(f"`{name}` ({owner}/{repo}) has no GitHub latest-release entry.")
            continue

        latest = release.get("tag_name")
        if not isinstance(latest, str) or not STABLE_TAG_RE.fullmatch(latest):
            skipped.append(f"`{name}` latest release tag is not a stable numeric version; skipped.")
            continue
        if latest == current:
            continue

        source_root_match = SOURCE_ROOT_RE.search(body)
        source_root = source_root_match.group(1).lstrip("/") if source_root_match else ""
        old_config = github.config_defaults(owner, repo, current, source_root)
        new_config = github.config_defaults(owner, repo, latest, source_root)
        new_hash = prefetch_hash(owner, repo, latest)

        updated_body = VERSION_RE.sub(
            lambda match: f'{match.group(1)}{latest}{match.group(3)}', body, count=1
        )
        updated_body = HASH_RE.sub(
            lambda match: f'{match.group(1)}{new_hash}{match.group(2)}', updated_body, count=1
        )
        old_block = block.group(0)
        new_block = old_block.replace(body, updated_body, 1)
        output = output.replace(old_block, new_block, 1)

        notes = (release.get("body") or "").strip()
        if len(notes) > 5000:
            notes = notes[:5000].rstrip() + "\n\n_(Release notes truncated.)_"
        updates.append(
            {
                "name": name,
                "owner": owner,
                "repo": repo,
                "current": current,
                "latest": latest,
                "url": release.get("html_url", f"https://github.com/{owner}/{repo}/releases"),
                "notes": notes or "No release notes were provided.",
                "config": config_change_summary(old_config, new_config),
            }
        )

    if updates:
        ANKI_NIX.write_text(output)

    sections = ["## Scheduled Anki add-on update report", ""]
    if updates:
        sections.extend(["### Proposed updates", ""])
        for update in updates:
            sections.extend(
                [
                    f"#### `{update['name']}`: `{update['current']}` → `{update['latest']}`",
                    f"Release: {update['url']}",
                    "",
                    "**Default config changes**",
                    *[f"- {line}" for line in update["config"]],
                    "",
                    "**Upstream release notes**",
                    "",
                    update["notes"],
                    "",
                ]
            )
    else:
        sections.extend(["No newer stable releases were found for the monitored Anki add-ons.", ""])

    if skipped:
        sections.extend(["### Not updated automatically", "", *[f"- {item}" for item in skipped], ""])

    report = "\n".join(sections).rstrip() + "\n"
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as summary:
            summary.write(report)
    body_path = os.environ.get("ANKI_ADDON_PR_BODY")
    if body_path and updates:
        Path(body_path).write_text(report, encoding="utf-8")

    print(report)
    if updates:
        print(f"Found {len(updates)} Anki add-on update(s).")


if __name__ == "__main__":
    main()
