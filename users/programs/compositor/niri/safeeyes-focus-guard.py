#!/usr/bin/env python3
"""Keep each active SafeEyes break focused on its own monitor in Niri."""

from __future__ import annotations

import json
import os
import socket
import subprocess
import sys
from typing import Any


APP_ID, TITLE_PREFIX, NIRI = sys.argv[1:4]
break_window_ids: set[int] = set()


def niri_json(*args: str) -> Any:
    result = subprocess.run(
        [NIRI, "msg", "-j", *args],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def ipc_action(name: str, fields: dict[str, Any]) -> None:
    # Target workspaces by their compositor ID. Workspace indices/names can
    # repeat across outputs, which could otherwise pull an overlay onto the
    # wrong monitor when another output has focus.
    socket_path = os.environ["NIRI_SOCKET"]
    request = json.dumps({"Action": {name: fields}}).encode() + b"\n"
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.connect(socket_path)
        connection.sendall(request)
        reply = connection.makefile("rb").readline()
    response = json.loads(reply)
    if "Err" in response:
        raise RuntimeError(response["Err"])


def refresh() -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    return niri_json("windows"), niri_json("workspaces")


def is_break(window: dict[str, Any]) -> bool:
    return window.get("app_id") == APP_ID and str(window.get("title", "")).startswith(
        TITLE_PREFIX
    )


def keep_break_on_output(output: str, focus_it: bool) -> None:
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

    overlays = [
        window
        for window in windows
        if is_break(window)
        and any(
            workspace.get("id") == window.get("workspace_id")
            and workspace.get("output") == output
            for workspace in workspaces
        )
    ]
    for overlay in overlays:
        if overlay.get("workspace_id") != active.get("id"):
            # The exact workspace ID keeps the break on this same output even
            # when another monitor has focus and uses the same workspace index.
            ipc_action(
                "MoveWindowToWorkspace",
                {
                    "window_id": overlay["id"],
                    "reference": {"Id": active["id"]},
                    "focus": False,
                },
            )

    if focus_it and overlays:
        # Moving is done without focus first; focusing the break afterwards
        # makes a same-workspace focus change unable to bypass the break.
        ipc_action("FocusWindow", {"id": overlays[0]["id"]})


def handle_event(event: dict[str, Any]) -> None:
    global break_window_ids

    snapshot = event.get("WindowsChanged")
    if snapshot is not None:
        break_window_ids = {
            window["id"] for window in snapshot.get("windows", []) if is_break(window)
        }
        return

    opened = event.get("WindowOpenedOrChanged", {}).get("window")
    if opened is not None:
        if is_break(opened):
            already_tracked = opened["id"] in break_window_ids
            break_window_ids.add(opened["id"])
            # SafeEyes can emit multiple updates for one break window during
            # startup. Only focus it on its first appearance; repeated focus
            # actions can cause pointer warps and make its controls awkward.
            if already_tracked:
                return
            windows, workspaces = refresh()
            workspace = next(
                (
                    workspace
                    for workspace in workspaces
                    if workspace.get("id") == opened.get("workspace_id")
                ),
                None,
            )
            if workspace is not None:
                keep_break_on_output(
                    str(workspace["output"]), focus_it=bool(workspace.get("is_focused"))
                )
        else:
            break_window_ids.discard(opened.get("id"))
        return

    closed = event.get("WindowClosed")
    if closed is not None:
        break_window_ids.discard(closed.get("id"))
        return

    # When no break is active, focus changes and workspace switches need no
    # compositor queries or actions.
    if not break_window_ids:
        return

    if "WindowFocusChanged" in event:
        windows, workspaces = refresh()
        focused = next((window for window in windows if window.get("is_focused")), None)
        if focused is None or is_break(focused):
            return
        workspace = next(
            (
                workspace
                for workspace in workspaces
                if workspace.get("id") == focused.get("workspace_id")
            ),
            None,
        )
        if workspace is not None:
            keep_break_on_output(str(workspace["output"]), focus_it=True)
        return

    activated = event.get("WorkspaceActivated")
    if activated is not None:
        workspaces = niri_json("workspaces")
        workspace = next(
            (workspace for workspace in workspaces if workspace.get("id") == activated.get("id")),
            None,
        )
        if workspace is not None:
            keep_break_on_output(
                str(workspace["output"]), focus_it=bool(activated.get("focused"))
            )
        return


def main() -> None:
    global break_window_ids

    # Reconcile any breaks already open when the service starts, preserving
    # their output assignment and focusing only the output currently in use.
    windows, workspaces = refresh()
    break_window_ids = {window["id"] for window in windows if is_break(window)}
    outputs_with_breaks = {
        workspace["output"]
        for window in windows
        if is_break(window)
        for workspace in workspaces
        if workspace.get("id") == window.get("workspace_id")
    }
    for output in outputs_with_breaks:
        focus_it = any(
            workspace.get("output") == output and workspace.get("is_focused")
            for workspace in workspaces
        )
        keep_break_on_output(str(output), focus_it=focus_it)

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
            # A transient compositor/event race is harmless; later focus or
            # workspace events will reconcile the break again.
            continue


if __name__ == "__main__":
    main()
