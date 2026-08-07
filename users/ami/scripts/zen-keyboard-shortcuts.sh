#!/usr/bin/env bash

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}ZEN KEYBOARD SHORTCUTS AUDITOR${NC}\n"

# 1. Locate nixos dir from anywhere
NIX_DIR=""
POSSIBLE_NIX_DIRS=(
  "${NIXOS_CONFIG_DIR:-}"
  "$HOME/nixos"
  "$HOME/.config/nixos"
  "$HOME/dotfiles/nixos"
  "$HOME/dotfiles"
)

for dir in "${POSSIBLE_NIX_DIRS[@]}"; do
  if [[ -n "$dir" && -d "$dir" ]]; then
    if grep -rq "keyboardShortcuts" "$dir" 2>/dev/null; then
      NIX_DIR="$dir"
      break
    fi
  fi
done

if [[ -z "$NIX_DIR" ]]; then
  echo -e "${RED}[!] Failed to locate Nix directory containing 'keyboardShortcuts'.${NC}"
  exit 1
fi

# 2. Find the exact Nix file defining keyboardShortcuts
NIX_FILE=$(grep -rl "keyboardShortcuts" "$NIX_DIR" 2>/dev/null | grep "\.nix$" | head -n 1 || true)

if [[ -z "$NIX_FILE" || ! -f "$NIX_FILE" ]]; then
  echo -e "${RED}[!] Failed to locate a .nix file defining 'keyboardShortcuts'.${NC}"
  exit 1
fi

# 3. Locate Zen's actual shortcuts JSON
ZEN_JSON="$HOME/.config/zen/default/zen-keyboard-shortcuts.json"
if [[ ! -f "$ZEN_JSON" ]]; then
  ZEN_JSON=$(find "$HOME/.config/zen" "$HOME/.mozilla/zen" -name "zen-keyboard-shortcuts.json" 2>/dev/null | head -n 1 || true)
fi

if [[ -z "$ZEN_JSON" || ! -f "$ZEN_JSON" ]]; then
  echo -e "${RED}[!] Failed to locate 'zen-keyboard-shortcuts.json'.${NC}"
  exit 1
fi

echo -e "nix config file : ${GREEN}${NIX_FILE}${NC}"
echo -e "zen profile JSON: ${GREEN}${ZEN_JSON}${NC}\n"

# 4. Extract all shortcut IDs defined in the Nix file
NIX_IDS=$(grep -oE 'id\s*=\s*"[^"]+"' "$NIX_FILE" | sed -E 's/id\s*=\s*"([^"]+)"/\1/' || true)

if [[ -z "$NIX_IDS" ]]; then
  echo -e "${YELLOW}[!] No shortcut IDs found in ${NIX_FILE}.${NC}"
  exit 0
fi

TOTAL_KEYS=$(echo "$NIX_IDS" | wc -l)
echo -e "${BLUE}Found $TOTAL_KEYS shortcuts in nix config file. Checking all against zen profile JSON${NC}\n"

# Create temporary file containing all valid IDs from Zen's JSON
ZEN_IDS_FILE=$(mktemp)
trap 'rm -f "$ZEN_IDS_FILE"' EXIT
jq -r '.shortcuts[] | select(.id != null) | .id' "$ZEN_JSON" > "$ZEN_IDS_FILE"

MATCHED=0
MISSING=0
MISMATCHES=0

while read -r nix_id; do
  [[ -z "$nix_id" ]] && continue

  # Check if ID exists in Zen JSON
  if grep -qxF "$nix_id" "$ZEN_IDS_FILE"; then
    
    # Extract values from Zen JSON using jq
    ZEN_KEY=$(jq -r --arg id "$nix_id" '.shortcuts[] | select(.id == $id) | .key // empty' "$ZEN_JSON" | head -n 1)
    ZEN_ACTION=$(jq -r --arg id "$nix_id" '.shortcuts[] | select(.id == $id) | .action // empty' "$ZEN_JSON" | head -n 1)
    ZEN_DISABLED=$(jq -r --arg id "$nix_id" '.shortcuts[] | select(.id == $id) | .disabled // empty' "$ZEN_JSON" | head -n 1)

    # Safe extract attrs from the Nix block using awk
    NIX_KEY=$(awk -v id="$nix_id" '
      $0 ~ "id = \"" id "\"" { in_b=1 }
      in_b && /}/ { in_b=0 }
      in_b && /key =/ {
        if (match($0, /"[^"]*"/)) {
          print substr($0, RSTART+1, RLENGTH-2)
        }
      }
    ' "$NIX_FILE" | head -n 1)

    NIX_ACTION=$(awk -v id="$nix_id" '
      $0 ~ "id = \"" id "\"" { in_b=1 }
      in_b && /}/ { in_b=0 }
      in_b && /action =/ {
        if (match($0, /"[^"]*"/)) {
          print substr($0, RSTART+1, RLENGTH-2)
        }
      }
    ' "$NIX_FILE" | head -n 1)

    NIX_DISABLED=$(awk -v id="$nix_id" '
      $0 ~ "id = \"" id "\"" { in_b=1 }
      in_b && /}/ { in_b=0 }
      in_b && /disabled =/ {
        if ($0 ~ /true/) print "true"
        if ($0 ~ /false/) print "false"
      }
    ' "$NIX_FILE" | head -n 1)

    DIFFS=""
    if [[ -n "$NIX_KEY" && "$NIX_KEY" != "$ZEN_KEY" ]]; then
      DIFFS+="key (Nix: '$NIX_KEY' vs Zen: '$ZEN_KEY') "
    fi
    if [[ -n "$NIX_ACTION" && "$NIX_ACTION" != "$ZEN_ACTION" ]]; then
      DIFFS+="action (Nix: '$NIX_ACTION' vs Zen: '$ZEN_ACTION') "
    fi
    if [[ -n "$NIX_DISABLED" && "$NIX_DISABLED" != "$ZEN_DISABLED" ]]; then
      DIFFS+="disabled (Nix: '$NIX_DISABLED' vs Zen: '$ZEN_DISABLED') "
    fi

    if [[ -n "$DIFFS" ]]; then
      echo -e "${YELLOW}[MISMATCH] '${nix_id}': ${DIFFS}${NC}"
      ((MISMATCHES++))
    else
      echo -e "${GREEN}[OK] '${nix_id}' exists and matches Zen JSON${NC}"
      ((MATCHED++))
    fi

  else
    echo -e "${RED}[MISSING IN ZEN] Shortcut ID '${nix_id}' does NOT exist in zen-keyboard-shortcuts.json!${NC}"
    ((MISSING++))
  fi
done <<< "$NIX_IDS"

echo -e "\n${BLUE}SUMMARY${NC}"
echo -e "  Total Checked   : ${TOTAL_KEYS}"
echo -e "  Valid / Matched : ${GREEN}${MATCHED}${NC}"
echo -e "  Mismatched Keys : ${YELLOW}${MISMATCHES}${NC}"
echo -e "  Missing IDs     : ${RED}${MISSING}${NC}"

if [[ "$MISSING" -gt 0 || "$MISMATCHES" -gt 0 ]]; then
  exit 1
fi