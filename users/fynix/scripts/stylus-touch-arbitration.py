#!/usr/bin/env python3
"""Suppress touchscreen touch while the FydeTab stylus is in proximity."""

from __future__ import annotations

import glob
import signal
import time
from selectors import EVENT_READ, DefaultSelector
from typing import Optional

from evdev import InputDevice, UInput, ecodes

TOUCHSCREEN_NAME = "himax-touchscreen"
STYLUS_NAME = "himax-stylus"
EVENT_GLOB = "/dev/input/event*"
TOUCHSCREEN_PATH = "/dev/input/by-path/platform-feac0000.i2c-event"

running = True


def request_stop(*_args: object) -> None:
    global running
    running = False


def find_device(
    name: str, preferred_path: Optional[str] = None
) -> Optional[InputDevice]:
    paths = ([preferred_path] if preferred_path else []) + sorted(glob.glob(EVENT_GLOB))
    seen: set[str] = set()

    for path in paths:
        if not path or path in seen:
            continue

        seen.add(path)

        try:
            device = InputDevice(path)
        except OSError:
            continue

        if device.name == name:
            return device
        device.close()

    return None


def release_contacts(output: UInput, slots: set[int], has_btn_touch: bool) -> None:
    for slot in sorted(slots):
        output.write(ecodes.EV_ABS, ecodes.ABS_MT_SLOT, slot)
        output.write(ecodes.EV_ABS, ecodes.ABS_MT_TRACKING_ID, -1)

    if has_btn_touch:
        output.write(ecodes.EV_KEY, ecodes.BTN_TOUCH, 0)

    if slots or has_btn_touch:
        output.syn()

    slots.clear()


def run(touch: InputDevice, stylus: InputDevice) -> None:
    output: Optional[UInput] = None
    selector: Optional[DefaultSelector] = None
    grabbed = False
    active_slots: set[int] = set()
    has_btn_touch = False

    try:
        touch.grab()
        grabbed = True
        output = UInput.from_device(
            touch,
            name="himax-touchscreen-arbitrated",
            phys="stylus-touch-arbitration/uinput",
        )
        selector = DefaultSelector()
        selector.register(touch, EVENT_READ, "touch")
        selector.register(stylus, EVENT_READ, "stylus")

        current_slot = 0
        touch_capabilities = touch.capabilities()
        has_btn_touch = ecodes.BTN_TOUCH in touch_capabilities.get(ecodes.EV_KEY, [])
        pen_in_proximity = any(
            code in stylus.active_keys()
            for code in (ecodes.BTN_TOOL_PEN, ecodes.BTN_TOOL_RUBBER)
        )

        while running:
            for selected_key, _ in selector.select(timeout=1):
                device = selected_key.fileobj
                source = selected_key.data

                for event in device.read():
                    if source == "stylus":
                        if event.type == ecodes.EV_KEY and event.code in (
                            ecodes.BTN_TOOL_PEN,
                            ecodes.BTN_TOOL_RUBBER,
                        ):
                            next_proximity = event.value != 0

                            if next_proximity and not pen_in_proximity:
                                release_contacts(output, active_slots, has_btn_touch)

                            pen_in_proximity = next_proximity
                        continue

                    if pen_in_proximity:
                        if (
                            event.type == ecodes.EV_SYN
                            and event.code == ecodes.SYN_REPORT
                        ):
                            active_slots.clear()
                        continue

                    if event.type == ecodes.EV_ABS:
                        if event.code == ecodes.ABS_MT_SLOT:
                            current_slot = event.value
                        elif event.code == ecodes.ABS_MT_TRACKING_ID:
                            if event.value < 0:
                                active_slots.discard(current_slot)
                            else:
                                active_slots.add(current_slot)

                    if event.type == ecodes.EV_SYN and event.code == ecodes.SYN_REPORT:
                        output.syn()
                    else:
                        output.write_event(event)
    finally:
        if selector is not None:
            selector.close()

        if output is not None:
            release_contacts(output, active_slots, has_btn_touch)
            output.close()

        if grabbed:
            try:
                touch.ungrab()
            except OSError:
                pass

        touch.close()
        stylus.close()


def main() -> int:
    signal.signal(signal.SIGTERM, request_stop)
    signal.signal(signal.SIGINT, request_stop)

    while running:
        touch = find_device(TOUCHSCREEN_NAME, TOUCHSCREEN_PATH)
        stylus = find_device(STYLUS_NAME)

        if touch is None or stylus is None:
            if touch is not None:
                touch.close()

            if stylus is not None:
                stylus.close()
            time.sleep(1)

            continue

        try:
            run(touch, stylus)
        except (OSError, RuntimeError) as error:
            if running:
                print(
                    f"stylus-touch-arbitration: restarting after input error: {error}",
                    flush=True,
                )
                time.sleep(1)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
