#!/usr/bin/env bash
# Wayle CI status module - auto-discovers repos with GitHub Actions
# Requires: gh CLI authenticated (gh auth login)
# Auto-detects repos from your account that have workflow runs

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ci-status"
REPO_CACHE_FILE="$STATE_DIR/repos.json"
ACK_FILE="$STATE_DIR/acknowledged.json"
mkdir -p "$STATE_DIR"

# Config (can override via env)
MAX_RUNS_PER_REPO="${CI_STATUS_MAX_RUNS:-5}"
MAX_AGE_DAYS="${CI_STATUS_MAX_AGE_DAYS:-14}"  # Ignore runs older than this
REPO_CACHE_TTL="${CI_STATUS_REPO_CACHE_TTL:-3600}"  # 1 hour
RUN_CACHE_TTL="${CI_STATUS_RUN_CACHE_TTL:-60}"      # 60 seconds

# Ensure ack file exists
[[ -f "$ACK_FILE" ]] || echo '[]' > "$ACK_FILE"

# Get list of user's repos (cached for 1 hour)
get_user_repos() {
    if [[ -f "$REPO_CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$REPO_CACHE_FILE" 2>/dev/null || echo 0))) -lt $REPO_CACHE_TTL ]]; then
        cat "$REPO_CACHE_FILE"
    else
        # Fetch all repos for authenticated user (public + private)
        gh repo list --limit 100 --json nameWithOwner,isPrivate --jq '[.[] | .nameWithOwner]' > "$REPO_CACHE_FILE" 2>/dev/null || echo '[]' > "$REPO_CACHE_FILE"
        cat "$REPO_CACHE_FILE"
    fi
}

# Acknowledge all currently failed runs (across all repos)
ack_all_failed() {
    REPOS_JSON=$(get_user_repos)
    echo "$REPOS_JSON" | jq -r '.[]' | while IFS= read -r REPO; do
        [[ -z "$REPO" ]] && continue
        CACHE_FILE="$STATE_DIR/cache_${REPO//\//_}.json"
        if [[ -f "$CACHE_FILE" ]]; then
            RUNS_JSON=$(cat "$CACHE_FILE")
            echo "$RUNS_JSON" | jq -r '.[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled") | "\(.databaseId) \(.workflowName)"' | while read -r id name; do
                jq --arg id "$id" '. + [$id] | unique' "$ACK_FILE" > "$ACK_FILE.tmp" && mv "$ACK_FILE.tmp" "$ACK_FILE"
                echo "Acknowledged: $name ($id)"
            done
        fi
    done
}

# Handle actions
ACTION="${1:-}"
case "$ACTION" in
    refresh)
        rm -f "$STATE_DIR"/cache_*.json "$REPO_CACHE_FILE"
        ;;
    open)
        # Open repo with most recent failed/running workflow
        REPOS_JSON=$(get_user_repos)
        TARGET_REPO=$(echo "$REPOS_JSON" | jq -r '.[]' | while IFS= read -r REPO; do
            [[ -z "$REPO" ]] && continue
            CACHE_FILE="$STATE_DIR/cache_${REPO//\//_}.json"
            if [[ -f "$CACHE_FILE" ]]; then
                RUNS_JSON=$(cat "$CACHE_FILE")
                # Check for failed or running
                HAS_RELEVANT=$(echo "$RUNS_JSON" | jq '[.[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled" or .conclusion == "" or .conclusion == null)] | length')
                if [[ $HAS_RELEVANT -gt 0 ]]; then
                    # Get most recent relevant run timestamp
                    LATEST=$(echo "$RUNS_JSON" | jq -r '.[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled" or .conclusion == "" or .conclusion == null) | .createdAt' | sort -r | head -1)
                    echo "$LATEST	$REPO"
                fi
            fi
        done | sort -r | head -1 | cut -f2)
        
        if [[ -n "$TARGET_REPO" ]]; then
            xdg-open "https://github.com/$TARGET_REPO/actions" 2>/dev/null || true
        else
            # Fallback to first repo
            FIRST_REPO=$(jq -r '.[0].full_name' "$REPO_CACHE_FILE" 2>/dev/null || echo "skifli/nixos")
            xdg-open "https://github.com/$FIRST_REPO/actions" 2>/dev/null || true
        fi
        ;;
    ack-menu)
        # Show fuzzel menu to pick action for failed runs
        # Style matching other fuzzel menus in the config
        FONT="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}"
        FONT_SIZE="${FONT_SIZE_APPLICATIONS:-11}"
        
        REPOS_JSON=$(get_user_repos)
        
        # Build menu items: "repo | workflow | conclusion | date | run_id" (no URL in display)
        MENU_ITEMS=$(echo "$REPOS_JSON" | jq -r '.[]' | while IFS= read -r REPO; do
            [[ -z "$REPO" ]] && continue
            CACHE_FILE="$STATE_DIR/cache_${REPO//\//_}.json"
            if [[ -f "$CACHE_FILE" ]]; then
                cat "$CACHE_FILE" | jq -r --arg repo "$REPO" '.[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled") | "\($repo) | \(.workflowName) | \(.conclusion) | \(.createdAt) | \(.databaseId)"'
            fi
        done)
        
        if [[ -z "$MENU_ITEMS" ]]; then
            notify-send -e -a "ci-status" -u low "No failed runs"
            exit 0
        fi
        
        # Calculate lines and width for fuzzel
        NUM_LINES=$(echo "$MENU_ITEMS" | wc -l)
        [ "$NUM_LINES" -gt 15 ] && NUM_LINES=15
        
        # Use fuzzel with consistent styling
        SELECTED=$(echo "$MENU_ITEMS" | fuzzel --dmenu \
            --font="$FONT:size=$FONT_SIZE" \
            --prompt="Failed runs (Enter=open, Ctrl+A=ack): " \
            --background-color=1e1e2eff \
            --text-color=cdd6f4ff \
            --input-color=cdd6f4ff \
            --selection-color=585b70ff \
            --selection-text-color=cdd6f4ff \
            --width=120 \
            --lines="$NUM_LINES" \
            --horizontal-pad=12 \
            --border-radius=10 \
            2>/dev/null)
        
        if [[ -z "$SELECTED" ]]; then
            exit 0
        fi
        
        # Extract run_id (last field)
        RUN_ID=$(echo "$SELECTED" | awk -F' \\| ' '{print $NF}')
        
        # Look up URL from cache JSON using run_id
        RUN_URL=$(echo "$REPOS_JSON" | jq -r '.[]' | while IFS= read -r REPO; do
            [[ -z "$REPO" ]] && continue
            CACHE_FILE="$STATE_DIR/cache_${REPO//\//_}.json"
            if [[ -f "$CACHE_FILE" ]]; then
                cat "$CACHE_FILE" | jq -r --arg id "$RUN_ID" '.[] | select(.databaseId == ($id | tonumber)) | .url' 2>/dev/null
            fi
        done | head -1)
        
        # Check if Shift was held (fuzzel sets FUZZEL_SELECTION_INDEX for custom actions?)
        # Since fuzzel doesn't easily support modifiers, use a second menu for action
        ACTION=$(printf "Open in browser\nAcknowledge (hide)\nCancel" | fuzzel --dmenu \
            --font="$FONT:size=$FONT_SIZE" \
            --prompt="Action for run $RUN_ID: " \
            --background-color=1e1e2eff \
            --text-color=cdd6f4ff \
            --input-color=cdd6f4ff \
            --selection-color=585b70ff \
            --selection-text-color=cdd6f4ff \
            --width=30 \
            --lines=3 \
            --horizontal-pad=12 \
            --border-radius=10 \
            2>/dev/null)
        
        case "$ACTION" in
            "Open in browser")
                xdg-open "$RUN_URL" 2>/dev/null || true
                ;;
            "Acknowledge (hide)")
                jq --arg id "$RUN_ID" '. + [$id] | unique' "$ACK_FILE" > "$ACK_FILE.tmp" && mv "$ACK_FILE.tmp" "$ACK_FILE"
                notify-send -e -a "ci-status" -u low "Acknowledged run $RUN_ID"
                ;;
            *)
                ;;
        esac
        exit 0
        ;;
    ack)
        # Acknowledge a failed run by ID (gh run list --json databaseId,conclusion)
        RUN_ID="${2:-}"
        if [[ -n "$RUN_ID" ]]; then
            jq --arg id "$RUN_ID" '. + [$id] | unique' "$ACK_FILE" > "$ACK_FILE.tmp" && mv "$ACK_FILE.tmp" "$ACK_FILE"
            echo "Acknowledged run $RUN_ID"
        fi
        exit 0
        ;;
    ack-all)
        # Acknowledge all currently failed runs
        ack_all_failed
        exit 0
        ;;
esac

REPOS_JSON=$(get_user_repos)

# Calculate cutoff timestamp (epoch seconds)
CUTOFF=$(( $(date +%s) - MAX_AGE_DAYS * 86400 ))

# Aggregate status across all repos
echo "$REPOS_JSON" | jq -r '.[]' | while IFS= read -r REPO; do
    [[ -z "$REPO" ]] && continue
    
    CACHE_FILE="$STATE_DIR/cache_${REPO//\//_}.json"
    
    # Read cached runs
    if [[ -f "$CACHE_FILE" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $RUN_CACHE_TTL ]]; then
        RUNS_JSON=$(cat "$CACHE_FILE")
    else
        # Fetch latest runs for this repo (all workflows)
        RUNS_JSON=$(gh run list --repo "$REPO" --limit "$MAX_RUNS_PER_REPO" --json databaseId,conclusion,status,headBranch,createdAt,url,displayTitle,workflowName 2>/dev/null || echo '[]')
        echo "$RUNS_JSON" > "$CACHE_FILE"
    fi
    
    if [[ "$RUNS_JSON" == "[]" ]] || [[ -z "$RUNS_JSON" ]]; then
        continue
    fi
    
    # Filter out old runs and acknowledged runs (acknowledged = hide completely)
    FILTERED_RUNS=$(echo "$RUNS_JSON" | jq --argjson cutoff "$CUTOFF" --argjson ack "$(cat "$ACK_FILE" | jq 'map(tonumber)')" '
        map(.databaseId as $id | select(
            (.createdAt | fromdateiso8601) >= $cutoff
            and (
                # Keep if not a failure/timed_out/cancelled
                (.conclusion != "failure" and .conclusion != "timed_out" and .conclusion != "cancelled")
                # AND not acknowledged (acknowledged runs are hidden completely)
                and ($ack | map(. == $id) | any | not)
            )
        ))
    ')
    
    if [[ "$FILTERED_RUNS" == "[]" ]]; then
        continue
    fi
    
    # Count statuses for this repo
    RUNNING=$(echo "$FILTERED_RUNS" | jq '[.[] | select(.conclusion == "" or .conclusion == null)] | length')
    FAILED=$(echo "$FILTERED_RUNS" | jq '[.[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled")] | length')
    SUCCESS=$(echo "$FILTERED_RUNS" | jq '[.[] | select(.conclusion == "success")] | length')
    PENDING=$(echo "$FILTERED_RUNS" | jq '[.[] | select(.conclusion != "success" and .conclusion != "failure" and .conclusion != "timed_out" and .conclusion != "cancelled" and .conclusion != "" and .conclusion != null)] | length')
    
    # Output counts for this repo
    echo "$REPO	$RUNNING	$FAILED	$SUCCESS	$PENDING"
    
done | awk -F'\t' '
    BEGIN { running=0; failed=0; success=0; pending=0; any=0 }
    { running+=$2; failed+=$3; success+=$4; pending+=$5; any=1 }
    END {
        if (any == 0) { print ""; exit }
        output=""
        if (running > 0) output = output "🟡 " running
        if (failed > 0) output = output "🔴 " failed
        if (success > 0 && running == 0 && failed == 0) output = output "🟢 " success
        if (pending > 0) output = output "⏳ " pending
        print output
    }
'