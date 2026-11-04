import json
import subprocess
import sys
import time

import websocket

TOPIC = "@TOPIC@"
SERVER = "@SERVER@"
TOKEN_PATH = "@TOKEN_PATH@"
NOTIFY_SEND = "@NOTIFY_SEND@"
ICON = "@ICON@"

# ntfy priority (1..5) -> (notify-send urgency, timeout ms)
# 0 means "never expire" (sticky).
URGENCY = {
    1: ("low", "10000"),
    2: ("low", "12000"),
    3: ("normal", "15000"),
    4: ("critical", "0"),
    5: ("critical", "0"),
}


def log(msg):
    print(msg, file=sys.stderr, flush=True)


def notify(title, body, priority=None):
    urgency, timeout = URGENCY.get(priority, URGENCY[3])
    args = [
        NOTIFY_SEND,
        "-a",
        "grafana",
        "-i",
        ICON,
        "-u",
        urgency,
        "-t",
        timeout,
    ]
    args += [title, body]
    try:
        subprocess.run(args, check=False, timeout=10)
    except Exception as exc:
        log("notify-send failed: %s" % exc)


def main():
    with open(TOKEN_PATH) as fh:
        token = fh.read().strip()

    url = SERVER.replace("https://", "wss://") + "/" + TOPIC + "/ws"
    headers = ["Authorization: Bearer " + token]

    while True:
        ws = None
        try:
            ws = websocket.create_connection(url, header=headers, timeout=120)
            log("connected to %s" % url)
            while True:
                raw = ws.recv()
                if not raw:
                    continue
                data = json.loads(raw)
                if data.get("event") == "message":
                    try:
                        priority = int(data.get("priority"))
                    except (TypeError, ValueError):
                        priority = None
                    notify(
                        data.get("title") or "Grafana alert",
                        data.get("message") or "",
                        priority,
                    )
        except Exception as exc:
            log("connection error: %s" % exc)
        finally:
            if ws is not None:
                try:
                    ws.close()
                except Exception:
                    pass
        time.sleep(5)


if __name__ == "__main__":
    main()
