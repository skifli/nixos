set -euo pipefail

set +e
"$SUNWAIT_BIN" poll $SUNWAIT_COORDS >/dev/null 2>&1
STATUS=$?
set -e

if [ "$STATUS" -eq 3 ]; then
  WANTED="dark"
elif [ "$STATUS" -eq 2 ]; then
  WANTED="light"
else
  echo "Sunwait error or unknown code: $STATUS" >&2
  exit 0
fi

CURRENT_SPEC=$(cat /etc/specialisation 2>/dev/null || echo "light") # The code defaults to light anyway

if [ "$WANTED" != "$CURRENT_SPEC" ]; then
  echo "Theme mismatch detected (current: $CURRENT_SPEC, wanted: $WANTED). Switching specialisation..." # Not notifying user since it's the middle of a HM rebuild so eh, probably before we were in the right theme anyway
  /run/wrappers/bin/sudo /run/current-system/specialisation/$WANTED/bin/switch-to-configuration switch
fi