#!/usr/bin/env bash
# Wayle GitHub Actions status, notifications, and run menu.
# Requires: gh authenticated with access to the user's repositories.

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ci-status"
REPO_CACHE_FILE="$STATE_DIR/repos.json"
ACK_FILE="$STATE_DIR/acknowledged.json"
WATCH_FILE="$STATE_DIR/watched-runs.json"
OUTPUT_FILE="$STATE_DIR/last-output.txt"
LOCK_FILE="$STATE_DIR/refresh.lock"
GITHUB_ICON="$HOME/.local/share/misc/github-icon.svg"
mkdir -p "$STATE_DIR"

MAX_RUNS_PER_REPO="${CI_STATUS_MAX_RUNS:-20}"
MAX_AGE_DAYS="${CI_STATUS_MAX_AGE_DAYS:-14}"
REPO_CACHE_TTL="${CI_STATUS_REPO_CACHE_TTL:-3600}"
RUN_CACHE_TTL="${CI_STATUS_RUN_CACHE_TTL:-60}"
ACTION="${1:-status}"
FORCE_REFRESH=0

# Serialise polling, refreshes, menus, and acknowledgements. If a periodic poll
# is already fetching data, the bar keeps its last complete snapshot instead of
# briefly displaying an empty result. Click actions wait for that fetch to end.
exec 9>"$LOCK_FILE"
if [[ "$ACTION" == "status" || "$ACTION" == "status-menu" || "$ACTION" == "ack-menu" ]]; then
    if ! flock -n 9; then
        if [[ "$ACTION" == "status" && -f "$OUTPUT_FILE" ]]; then
            cat "$OUTPUT_FILE"
        fi
        exit 0
    fi
else
    flock -x 9
fi

atomic_write() {
    local destination="$1" temporary
    temporary=$(mktemp "$STATE_DIR/.ci-status.XXXXXX")
    cat > "$temporary"
    chmod 600 "$temporary"
    mv -f -- "$temporary" "$destination"
}

ensure_json_file() {
    local path="$1" default="$2" expected_type="$3"
    if [[ ! -f "$path" ]] || ! jq -e --arg expected "$expected_type" 'type == $expected' "$path" >/dev/null 2>&1; then
        printf '%s\n' "$default" | atomic_write "$path"
    fi
}

cache_is_fresh() {
    local path="$1" ttl="$2" age
    [[ -f "$path" ]] || return 1
    age=$(( $(date +%s) - $(stat -c %Y "$path" 2>/dev/null || echo 0) ))
    (( age < ttl ))
}

ensure_json_file "$ACK_FILE" '[]' array
ensure_json_file "$WATCH_FILE" '{}' object

get_user_repos() {
    local fetched
    if (( ! FORCE_REFRESH )) && cache_is_fresh "$REPO_CACHE_FILE" "$REPO_CACHE_TTL" \
        && jq -e 'type == "array"' "$REPO_CACHE_FILE" >/dev/null 2>&1; then
        cat "$REPO_CACHE_FILE"
        return
    fi

    if fetched=$(gh repo list --limit 100 --json nameWithOwner,isPrivate --jq '[.[] | .nameWithOwner]' 2>/dev/null) \
        && jq -e 'type == "array"' <<<"$fetched" >/dev/null 2>&1; then
        printf '%s\n' "$fetched" | atomic_write "$REPO_CACHE_FILE"
        printf '%s\n' "$fetched"
    elif [[ -f "$REPO_CACHE_FILE" ]] && jq -e 'type == "array"' "$REPO_CACHE_FILE" >/dev/null 2>&1; then
        cat "$REPO_CACHE_FILE"
    else
        printf '[]\n'
    fi
}

get_repo_runs() {
    local repo="$1" cache_file="$STATE_DIR/cache_${1//\//_}.json" fetched
    if (( ! FORCE_REFRESH )) && cache_is_fresh "$cache_file" "$RUN_CACHE_TTL" \
        && jq -e 'type == "array"' "$cache_file" >/dev/null 2>&1; then
        cat "$cache_file"
        return
    fi

    if fetched=$(gh run list --repo "$repo" --limit "$MAX_RUNS_PER_REPO" \
        --json databaseId,conclusion,status,headBranch,createdAt,url,displayTitle,workflowName 2>/dev/null) \
        && jq -e 'type == "array"' <<<"$fetched" >/dev/null 2>&1; then
        printf '%s\n' "$fetched" | atomic_write "$cache_file"
        printf '%s\n' "$fetched"
    elif [[ -f "$cache_file" ]] && jq -e 'type == "array"' "$cache_file" >/dev/null 2>&1; then
        # Keep the last good data if GitHub is temporarily unavailable.
        cat "$cache_file"
    else
        printf '[]\n'
    fi
}

load_all_runs() {
    local repo runs tagged
    REPOS_JSON=$(get_user_repos)
    ALL_RUNS_JSON='[]'
    while IFS= read -r repo; do
        [[ -z "$repo" ]] && continue
        runs=$(get_repo_runs "$repo")
        tagged=$(jq --arg repo "$repo" 'map(. + {repository: $repo})' <<<"$runs")
        ALL_RUNS_JSON=$(jq -cn --argjson left "$ALL_RUNS_JSON" --argjson right "$tagged" '$left + $right')
    done < <(jq -r '.[]' <<<"$REPOS_JSON")
}

notify_ci() {
    local title="$1" body="$2"
    if [[ -r "$GITHUB_ICON" ]]; then
        notify-send -e -a "ci-status" -i "$GITHUB_ICON" -u low -t 7000 "$title" "$body" || true
    else
        notify-send -e -a "ci-status" -u low -t 7000 "$title" "$body" || true
    fi
}

ack_run() {
    local id="$1"
    jq --arg id "$id" '. + [$id] | unique' "$ACK_FILE" | atomic_write "$ACK_FILE"
    jq --arg id "$id" 'del(.[$id])' "$WATCH_FILE" | atomic_write "$WATCH_FILE"
}

CUTOFF=$(( $(date +%s) - MAX_AGE_DAYS * 86400 ))

notify_run_transitions() {
    local ack_json tracked initialized run id repo workflow title conclusion status previous body state_label next_state
    ack_json=$(cat "$ACK_FILE")
    tracked=$(jq -c 'if type == "object" then . else {} end' "$WATCH_FILE")
    initialized=$(jq -r '._initialized // false' <<<"$tracked")

    while IFS= read -r run; do
        id=$(jq -r '.databaseId | tostring' <<<"$run")
        repo=$(jq -r '.repository // "unknown repository"' <<<"$run")
        workflow=$(jq -r '.workflowName // "GitHub Actions"' <<<"$run")
        title=$(jq -r '.displayTitle // .headBranch // "Workflow run"' <<<"$run")
        status=$(jq -r '.status // ""' <<<"$run")
        conclusion=$(jq -r '.conclusion // ""' <<<"$run")

        if jq -e --arg id "$id" 'index($id) != null' <<<"$ack_json" >/dev/null; then
            tracked=$(jq --arg id "$id" 'del(.[$id])' <<<"$tracked")
            continue
        fi

        previous=$(jq -r --arg id "$id" '.[$id].state // ""' <<<"$tracked")
        body="$repo — $workflow: $title"

        if [[ -z "$previous" ]]; then
            if [[ "$status" == "in_progress" ]]; then
                state_label="in progress"
                next_state="running"
            elif [[ -n "$conclusion" ]]; then
                state_label="$conclusion"
                next_state="finished:$conclusion"
            else
                state_label="${status:-queued}"
                next_state="${status:-queued}"
            fi
            if [[ "$initialized" == "true" ]]; then
                notify_ci "New workflow run" "$body ($state_label)"
            fi
            tracked=$(jq --arg id "$id" --arg repo "$repo" --arg workflow "$workflow" \
                --arg title "$title" --arg state "$next_state" --arg seen_at "$(date -Is)" \
                '.[$id] = {state: $state, repo: $repo, workflow: $workflow, title: $title, seenAt: $seen_at}' \
                <<<"$tracked")
            continue
        fi

        if [[ "$status" == "in_progress" ]]; then
            if [[ "$previous" != "running" ]]; then
                notify_ci "Workflow in progress" "$body"
                tracked=$(jq --arg id "$id" --arg repo "$repo" --arg workflow "$workflow" \
                    --arg title "$title" --arg seen_at "$(date -Is)" \
                    '.[$id] = {state: "running", repo: $repo, workflow: $workflow, title: $title, seenAt: $seen_at}' \
                    <<<"$tracked")
            fi
        elif [[ "$previous" != finished:* && -n "$conclusion" ]]; then
            if [[ "$conclusion" == "success" ]]; then
                notify_ci "Workflow succeeded" "$body"
            fi
            # A newly discovered failure gets the discovery notice; later
            # failures stay quiet because GitHub already sends an email.
            tracked=$(jq --arg id "$id" --arg conclusion "$conclusion" \
                '.[$id].state = ("finished:" + $conclusion)' <<<"$tracked")
        fi
    done < <(jq -c --argjson cutoff "$CUTOFF" 'map(select((.createdAt | fromdateiso8601) >= $cutoff))[]' <<<"$ALL_RUNS_JSON")

    printf '%s\n' "$(jq '._initialized = true' <<<"$tracked")" | atomic_write "$WATCH_FILE"
}

summarize_status() {
    local ack_json filtered running failed success pending output
    ack_json=$(cat "$ACK_FILE")
    filtered=$(jq --argjson cutoff "$CUTOFF" --argjson ack "$ack_json" '
        map(select((.createdAt | fromdateiso8601) >= $cutoff))
        | group_by([.repository, (.workflowName // "GitHub Actions")])
        | map(max_by(.createdAt))
        | map(.databaseId as $id | select(($ack | index($id | tostring)) == null))
    ' <<<"$ALL_RUNS_JSON")

    running=$(jq '[.[] | select(.status == "in_progress")] | length' <<<"$filtered")
    failed=$(jq '[.[] | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled")] | length' <<<"$filtered")
    success=$(jq '[.[] | select(.conclusion == "success")] | length' <<<"$filtered")
    pending=$(jq '[.[] | select(.status == "queued" or .status == "requested" or .status == "waiting" or .status == "pending")] | length' <<<"$filtered")

    output=""
    (( running > 0 )) && output+="🟡 $running "
    (( failed > 0 )) && output+="🔴 $failed "
    if (( success > 0 && running == 0 && failed == 0 )); then output+="🟢 $success "; fi
    (( pending > 0 )) && output+="⏳ $pending "
    printf '%s' "${output% }"
}

show_status_menu() {
    local ack_json menu_items selected run_id run_url menu_action lines
    ack_json=$(cat "$ACK_FILE")
    menu_items=$(jq -r --argjson cutoff "$CUTOFF" --argjson ack "$ack_json" '
        map(select((.createdAt | fromdateiso8601) >= $cutoff))
        | group_by([.repository, (.workflowName // "GitHub Actions")])
        | map(max_by(.createdAt))
        | map(.databaseId as $id | select(($ack | index($id | tostring)) == null))
        | sort_by([(.status == "in_progress"), .createdAt]) | reverse
        | .[]
        | . as $run
        | (if .conclusion == "success" then "SUCCESS"
           elif .conclusion == "failure" then "FAILURE"
           elif .conclusion == "timed_out" then "TIMED OUT"
           elif .conclusion == "cancelled" then "CANCELLED"
           elif .status == "in_progress" then "IN PROGRESS"
           elif .status == "queued" or .status == "requested" or .status == "waiting" then "QUEUED"
           else (.status // "UNKNOWN" | ascii_upcase) end) as $state
        | "\($state) | \(.repository) | \(.workflowName // "GitHub Actions") | \(.displayTitle // .headBranch // "Workflow run") | \(.createdAt) | \(.databaseId)"
    ' <<<"$ALL_RUNS_JSON")

    if [[ -z "$menu_items" ]]; then
        notify_ci "No recent workflows" "No workflow runs were found in the last $MAX_AGE_DAYS days."
        return
    fi

    lines=$(wc -l <<<"$menu_items")
    (( lines > 20 )) && lines=20
    selected=$(printf '%s\n' "$menu_items" | fuzzel --dmenu \
        --font="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}:size=${FONT_SIZE_APPLICATIONS:-11}" \
        --prompt="GitHub Actions: " \
        --background-color=1e1e2eff --text-color=cdd6f4ff --input-color=cdd6f4ff \
        --selection-color=585b70ff --selection-text-color=cdd6f4ff \
        --width=130 --lines="$lines" --horizontal-pad=12 --border-radius=10 2>/dev/null) || true
    [[ -z "$selected" ]] && return

    run_id="${selected##* | }"
    run_url=$(jq -r --arg id "$run_id" '.[] | select((.databaseId | tostring) == $id) | .url' <<<"$ALL_RUNS_JSON" | head -n 1)
    menu_action=$(printf 'Open in browser\nAcknowledge (hide)\nCancel' | fuzzel --dmenu \
        --font="${FONT_MONOSPACE:-JetBrainsMono Nerd Font}:size=${FONT_SIZE_APPLICATIONS:-11}" \
        --prompt="Workflow $run_id: " \
        --background-color=1e1e1eff --text-color=cdd6f4ff --input-color=cdd6f4ff \
        --selection-color=585b70ff --selection-text-color=cdd6f4ff \
        --width=35 --lines=3 --horizontal-pad=12 --border-radius=10 2>/dev/null) || true

    case "$menu_action" in
        "Open in browser") [[ -n "$run_url" ]] && xdg-open "$run_url" 2>/dev/null || true ;;
        "Acknowledge (hide)")
            ack_run "$run_id"
            notify_ci "Workflow hidden" "Acknowledged workflow run $run_id."
            ;;
    esac
}

case "$ACTION" in
    refresh)
        # Keep the displayed snapshot while replacing caches under the lock.
        FORCE_REFRESH=1
        ;;
    status-menu|ack-menu)
        load_all_runs
        notify_run_transitions
        show_status_menu
        exit 0
        ;;
    open)
        load_all_runs
        TARGET_URL=$(jq -r '
            group_by([.repository, (.workflowName // "GitHub Actions")])
            | map(max_by(.createdAt))
            | map(select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled" or .status != "completed"))
            | sort_by(.createdAt) | last | .url // empty
        ' <<<"$ALL_RUNS_JSON")
        if [[ -n "$TARGET_URL" ]]; then
            xdg-open "$TARGET_URL" 2>/dev/null || true
        else
            FIRST_REPO=$(jq -r '.[0] // "skifli/nixos"' <<<"$REPOS_JSON")
            xdg-open "https://github.com/$FIRST_REPO/actions" 2>/dev/null || true
        fi
        exit 0
        ;;
    ack)
        [[ -n "${2:-}" ]] && ack_run "$2"
        exit 0
        ;;
    ack-all)
        load_all_runs
        FAILED_IDS=$(jq -r --argjson cutoff "$CUTOFF" '
            .[] | select((.createdAt | fromdateiso8601) >= $cutoff)
            | select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "cancelled")
            | .databaseId | tostring
        ' <<<"$ALL_RUNS_JSON")
        while IFS= read -r id; do [[ -n "$id" ]] && ack_run "$id"; done <<<"$FAILED_IDS"
        exit 0
        ;;
    status) ;;
    *) echo "Unknown action: $ACTION" >&2; exit 2 ;;
esac

load_all_runs
notify_run_transitions
STATUS_OUTPUT=$(summarize_status)
printf '%s' "$STATUS_OUTPUT" | atomic_write "$OUTPUT_FILE"
printf '%s' "$STATUS_OUTPUT"
