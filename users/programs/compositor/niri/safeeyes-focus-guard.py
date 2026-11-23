#!/usr/bin/env python3
"""Keep SafeEyes break windows tiled on their assigned Niri output."""

from __future__ import annotations

import json
import os
import re
import socket
import subprocess
import sys
from typing import Any


APP_ID, TITLE_PREFIX, NIRI, OUTPUTS_JSON = sys.argv[1:5]
OUTPUTS = json.loads(OUTPUTS_JSON)
break_window_ids: set[int] = set()


def niri_json(*args: str) -> Any:
    result = subprocess.run(
        [NIRI, "msg", "-j", *args], check=True, capture_output=True, text=True
    )
    return json.loads(result.stdout)


def ipc_action(name: str, fields: dict[str, Any]) -> None:
    request = json.dumps({"Action": {name: fields}}).encode() + b"\n"
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.connect(os.environ["NIRI_SOCKET"])
        connection.sendall(request)
        reply = connection.makefile("rb").readline()
    response = json.loads(reply)
    if "Err" in response:
        raise RuntimeError(response["Err"])


def is_break(window: dict[str, Any]) -> bool:
    return window.get("app_id") == APP_ID and str(window.get("title", "")).startswith(
        TITLE_PREFIX
    )


def assigned_output(window: dict[str, Any]) -> str | None:
    title = str(window.get("title", ""))
    if not is_break(window):
        return None
    match = re.match(r"^(\d+)", title[len(TITLE_PREFIX) :])
    if match is None:
        return None
    index = int(match.group(1))
    return OUTPUTS[index] if 0 <= index < len(OUTPUTS) else None


def refresh() -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    return niri_json("windows"), niri_json("workspaces")


def keep_breaks_on_output(output: str, focus_it: bool = False) -> None:
    windows, workspaces = refresh()
    active = next(
        (
            workspace
            for workspace in workspaces
            if workspace.get("output") == output and workspace.get("is_active")
        ),
        None,
    )
    if active is None:
        return

    overlays = [window for window in windows if assigned_output(window) == output]
    for overlay in overlays:
        if overlay.get("workspace_id") != active.get("id"):
            ipc_action(
                "MoveWindowToWorkspace",
                {
                    "window_id": overlay["id"],
                    "reference": {"Id": active["id"]},
                    "focus": False,
                },
            )
        # Niri 26.04 has no idempotent fullscreen-set action or fullscreen state
        # in its window snapshot. Keep the break out of floating mode here;
        # `open-fullscreen = true` handles its initial state in the window rule.
        if overlay.get("is_floating"):
            ipc_action("MoveWindowToTiling", {"id": overlay["id"]})

    if focus_it and overlays:
        ipc_action("FocusWindow", {"id": overlays[0]["id"]})


def reconcile_active(focus_output: str | None = None) -> None:
    windows, workspaces = refresh()
    active_outputs = {
        workspace.get("output")
        for workspace in workspaces
        if workspace.get("is_active")
        and any(assigned_output(window) == workspace.get("output") for window in windows)
    }
    for output in active_outputs:
        if output is not None:
            keep_breaks_on_output(output, focus_it=output == focus_output)


def handle_event(event: dict[str, Any]) -> None:
    global break_window_ids

    snapshot = event.get("WindowsChanged")
    if snapshot is not None:
        windows = snapshot.get("windows", [])
        break_window_ids = {window["id"] for window in windows if is_break(window)}
        reconcile_active()
        return

    opened = event.get("WindowOpenedOrChanged", {}).get("window")
    if opened is not None:
        if is_break(opened):
            break_window_ids.add(opened["id"])
            output = assigned_output(opened)
            if output is not None:
                workspaces = niri_json("workspaces")
                active = next(
                    (
                        workspace
                        for workspace in workspaces
                        if workspace.get("output") == output
                        and workspace.get("is_active")
                    ),
                    None,
                )
                keep_breaks_on_output(
                    output,
                    focus_it=bool(active and active.get("is_focused")),
                )
        else:
            break_window_ids.discard(opened.get("id"))
        return

    closed = event.get("WindowClosed")
    if closed is not None:
        break_window_ids.discard(closed.get("id"))
        return

    if not break_window_ids:
        return

    if "WindowFocusChanged" in event:
        windows, workspaces = refresh()
        focused = next((window for window in windows if window.get("is_focused")), None)
        if focused is None or is_break(focused):
            return
        workspace = next(
            (ws for ws in workspaces if ws.get("id") == focused.get("workspace_id")),
            None,
        )
        if workspace is not None:
            keep_breaks_on_output(str(workspace["output"]), focus_it=True)
        return

    activated = event.get("WorkspaceActivated")
    if activated is not None:
        workspace = next(
            (
                ws
                for ws in niri_json("workspaces")
                if ws.get("id") == activated.get("id")
            ),
            None,
        )
        if workspace is not None:
            keep_breaks_on_output(
                str(workspace["output"]), focus_it=bool(activated.get("is_focused"))
            )


def main() -> None:
    global break_window_ids

    windows, workspaces = refresh()
    break_window_ids = {window["id"] for window in windows if is_break(window)}
    focused_output = next(
        (workspace.get("output") for workspace in workspaces if workspace.get("is_focused")),
        None,
    )
    reconcile_active(focus_output=focused_output)

    stream = subprocess.Popen(
        [NIRI, "msg", "-j", "event-stream"],
        stdout=subprocess.PIPE,
        text=True,
        bufsize=1,
    )
    assert stream.stdout is not None
    for line in stream.stdout:
        try:
            event = json.loads(line)
            if isinstance(event, dict):
                handle_event(event)
        except (
            json.JSONDecodeError,
            KeyError,
            OSError,
            RuntimeError,
            subprocess.SubprocessError,
        ):
            continue


if __name__ == "__main__":
    main()
