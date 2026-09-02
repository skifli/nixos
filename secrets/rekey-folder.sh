#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <folder_name> [path_to_private_key]"
    echo "Example: $0 fynix ./id_ed25519"
    exit 1
fi

FOLDER="$1"
IDENTITY_FLAG=""

if [ "${2:-}" != "" ]; then
    IDENTITY_FLAG="-i $2"
fi

MAIN_RULES="secrets/secrets.nix"
TEMP_RULES="secrets/secrets_temp_${FOLDER}.nix"

echo "Isolating folder: secrets/${FOLDER}/..."

sed -n '1,/in {/p' "$MAIN_RULES" > "$TEMP_RULES"

grep "secrets/${FOLDER}/" "$MAIN_RULES" >> "$TEMP_RULES" || true

echo "}" >> "$TEMP_RULES"

export RULES="$TEMP_RULES"
echo "Running agenix --rekey..."
agenix --rekey $IDENTITY_FLAG

rm -f "$TEMP_RULES"
echo "Rekeying for secrets/${FOLDER}/ completed successfully!"
