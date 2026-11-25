#!/usr/bin/env bash
# Wayle GitHub Actions status, notifications, and run menu.
# Requires: gh authenticated with access to the user's repositories.

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ci-status"
REPO_CACHE_FILE="$STATE_DIR/repos.json"
REPO_FILTER_FILE="$STATE_DIR/repos.filter"
ALL_RUNS_FILE="$STATE_DIR/all-runs.json"
ACK_FILE="$STATE_DIR/acknowledged.json"
WATCH_FILE="$STATE_DIR/watched-runs.json"
OUTPUT_FILE="$STATE_DIR/last-output.txt"
AUTH_STATE_FILE="$STATE_DIR/github-auth-state"
LOCK_FILE="$STATE_DIR/refresh.lock"
ACK_LOCK_FILE="$STATE_DIR/acknowledged.lock"
GITHUB_ICON="$HOME/.local/share/misc/github-icon.svg"
mkdir -p "$STATE_DIR"

MAX_RUNS_PER_REPO="${CI_STATUS_MAX_RUNS:-20}"
MAX_AGE_DAYS="${CI_STATUS_MAX_AGE_DAYS:-14}"
REPO_CACHE_TTL="${CI_STATUS_REPO_CACHE_TTL:-3600}"
# A 60s TTL over a large org scan burns through GitHub's 5,000 requests/hour
# quota (~240 repos x 60 polls/hour = 14,400 requests). Five minutes keeps a
# full scan comfortably below the limit while still feeling live.
RUN_CACHE_TTL="${CI_STATUS_RUN_CACHE_TTL:-300}"
NOTIFY_BATCH_GRACE="${CI_STATUS_BATCH_GRACE:-180}"
# CI_STATUS_ORGS (unset) scans every organisation the account belongs to.
# Set it to a comma-separated list of organisations to restrict the scan.
REPO_PARALLELISM="${CI_STATUS_PARALLEL:-10}"
ACTION="${1:-status}"
FORCE_REFRESH=0

# Keep refresh and notification state serialised. Menus read the last atomic
# snapshot so opening one never waits for GitHub's API.
exec 9>"$LOCK_FILE"
exec 8>"$ACK_LOCK_FILE"
if [[ "$ACTION" == "status-menu" || "$ACTION" == "open" ]]; then
    : # These actions use cached data and must stay responsive during a refresh.
elif [[ "$ACTION" == "status" || "$ACTION" == "ack-menu" ]]; then
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
    local user_repos org_repos org_list all_repos current_filter cached_filter
    current_filter="${CI_STATUS_ORGS:-__all__}"
    cached_filter=$(cat "$REPO_FILTER_FILE" 2>/dev/null || true)
    if (( ! FORCE_REFRESH )) && [[ "$cached_filter" == "$current_filter" ]] \
        && cache_is_fresh "$REPO_CACHE_FILE" "$REPO_CACHE_TTL" \
        && jq -e 'type == "array"' "$REPO_CACHE_FILE" >/dev/null 2>&1; then
        cat "$REPO_CACHE_FILE"
        return
    fi

    # Repos owned by the authenticated user.
    if user_repos=$(gh repo list --limit 100 --json nameWithOwner,isPrivate --jq '[.[] | .nameWithOwner]' 2>/dev/null) \
        && jq -e 'type == "array"' <<<"$user_repos" >/dev/null 2>&1; then
        :
    else
        user_repos='[]'
    fi

    # Repos owned by organisations. Unset CI_STATUS_ORGS discovers every
    # organisation the account belongs to; set it to a comma-separated list
    # to restrict the scan.
    if [[ -n "${CI_STATUS_ORGS:-}" ]]; then
        org_list=$(printf '%s\n' "$CI_STATUS_ORGS" | tr ',' '\n')
    else
        org_list=$(gh api --paginate /user/orgs --jq '.[].login' 2>/dev/null || true)
    fi

    if org_repos=$(printf '%s\n' "$org_list" | while read -r org; do
        [[ -z "$org" ]] && continue
        gh repo list "$org" --limit 100 --json nameWithOwner,isPrivate --jq '[.[] | .nameWithOwner]' 2>/dev/null || true
    done | jq -s 'flatten') \
        && jq -e 'type == "array"' <<<"$org_repos" >/dev/null 2>&1; then
        :
    else
        org_repos='[]'
    fi

    all_repos=$(jq -cn --argjson user "$user_repos" --argjson org "$org_repos" '$user + $org | unique_by(.)')
    if [[ "$all_repos" != "[]" ]] || [[ ! -f "$REPO_CACHE_FILE" ]]; then
        printf '%s\n' "$all_repos" | atomic_write "$REPO_CACHE_FILE"
        # Written after the repo list so an interrupted refresh cannot make a
        # stale list look current.
        printf '%s\n' "$current_filter" | atomic_write "$REPO_FILTER_FILE"
        printf '%s\n' "$all_repos"
    elif [[ "$cached_filter" == "$current_filter" ]]; then
        # GitHub was unreachable: keep the last good repo list.
        cat "$REPO_CACHE_FILE"
    else
        # The filter changed and GitHub was unreachable. Scan nothing rather
        # than fall back to a list from a different (possibly larger) scope.
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
        --json databaseId,conclusion,status,headBranch,headSha,createdAt,url,displayTitle,workflowName 2>/dev/null) \
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
    local repo runs tagged max_parallel files file
    REPOS_JSON=$(get_user_repos)
    max_parallel="${CI_STATUS_PARALLEL:-10}"

    rm -f "$STATE_DIR"/tagged_*.json
    while IFS= read -r repo; do
        [[ -z "$repo" ]] && continue
        # One GitHub request per repo, throttled to max_parallel at a time.
        while (( $(jobs -rp | wc -l) >= max_parallel )); do
            wait -n || true
        done
        (
            runs=$(get_repo_runs "$repo")
            jq --arg repo "$repo" 'map(. + {repository: $repo})' <<<"$runs" \
                > "$STATE_DIR/tagged_${repo//\//_}.json"
        ) &
    done < <(jq -r '.[]' <<<"$REPOS_JSON")
    wait

    files=()
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find "$STATE_DIR" -maxdepth 1 -name 'tagged_*.json' -print0)
    if (( ${#files[@]} > 0 )); then
        ALL_RUNS_JSON=$(jq -s 'flatten' "${files[@]}")
    else
        ALL_RUNS_JSON='[]'
    fi
    printf '%s\n' "$ALL_RUNS_JSON" | atomic_write "$ALL_RUNS_FILE"
}

load_cached_runs() {
    local repo cache_file runs tagged
    ALL_RUNS_JSON='[]'
    REPOS_JSON='[]'

    if [[ -f "$ALL_RUNS_FILE" ]] && jq -e 'type == "array"' "$ALL_RUNS_FILE" >/dev/null 2>&1; then
        ALL_RUNS_JSON=$(cat "$ALL_RUNS_FILE")
        REPOS_JSON=$(cat "$REPO_CACHE_FILE" 2>/dev/null || printf '[]\n')
        return
    fi

    # Migrate existing per-repository caches into the combined snapshot without
    # making the first menu click perform network requests.
    if [[ -f "$REPO_CACHE_FILE" ]] && jq -e 'type == "array"' "$REPO_CACHE_FILE" >/dev/null 2>&1; then
        REPOS_JSON=$(cat "$REPO_CACHE_FILE")
        while IFS= read -r repo; do
            [[ -z "$repo" ]] && continue
            cache_file="$STATE_DIR/cache_${repo//\//_}.json"
            [[ -f "$cache_file" ]] || continue
            jq -e 'type == "array"' "$cache_file" >/dev/null 2>&1 || continue
            runs=$(cat "$cache_file")
            tagged=$(jq --arg repo "$repo" 'map(. + {repository: $repo})' <<<"$runs")
            ALL_RUNS_JSON=$(jq -cn --argjson left "$ALL_RUNS_JSON" --argjson right "$tagged" '$left + $right')
        done < <(jq -r '.[]' <<<"$REPOS_JSON")
    fi
}

# CI notifications use the repo as the app name (where "ci-status" used to
# be), the workflow + state as the summary, and the commit title as the body.
notify_ci() {
    local repo="$1" summary="$2" body="$3"
    if [[ -r "$GITHUB_ICON" ]]; then
        notify-send -e -a "$repo" -i "$GITHUB_ICON" -u low -t 7000 "$summary" "$body" || true
    else
        notify-send -e -a "$repo" -u low -t 7000 "$summary" "$body" || true
    fi
}

# Generic messages about the module itself (menus, acknowledgements).
notify_msg() {
    local summary="$1" body="$2"
    if [[ -r "$GITHUB_ICON" ]]; then
        notify-send -e -a "ci-status" -i "$GITHUB_ICON" -u low -t 7000 "$summary" "$body" || true
    else
        notify-send -e -a "ci-status" -u low -t 7000 "$summary" "$body" || true
    fi
}

report_missing_github_auth() {
    local previous_state
    previous_state=$(cat "$AUTH_STATE_FILE" 2>/dev/null || true)
    if [[ "$previous_state" != "unauthenticated" ]]; then
        notify_msg "GitHub login needed" "CI status cannot load workflows. Run gh auth login, then it will refresh automatically."
        printf 'unauthenticated\n' | atomic_write "$AUTH_STATE_FILE"
    fi
}

# Check for a locally available GitHub credential before touching caches.
# Without this guard, gh failures were converted to empty repo/run arrays and
# cached, so Wayle looked like there were no workflows and could stay empty
# after the user signed in.
if gh auth token --hostname github.com >/dev/null 2>&1; then
    PREVIOUS_AUTH_STATE=$(cat "$AUTH_STATE_FILE" 2>/dev/null || true)
    if [[ "$PREVIOUS_AUTH_STATE" != "authenticated" ]]; then
        # Discard empty snapshots made while unauthenticated, forcing the next
        # poll to fetch repositories and workflows with the restored login.
        if [[ "$PREVIOUS_AUTH_STATE" == "unauthenticated" ]] \
            || jq -e 'type == "array" and length == 0' "$REPO_CACHE_FILE" >/dev/null 2>&1; then
            rm -f "$REPO_CACHE_FILE" "$REPO_FILTER_FILE" "$ALL_RUNS_FILE"
        fi
        printf 'authenticated\n' | atomic_write "$AUTH_STATE_FILE"
        if [[ "$PREVIOUS_AUTH_STATE" == "unauthenticated" ]]; then
            notify_msg "GitHub login restored" "Refreshing CI status now."
        fi
    fi
    GH_AUTHENTICATED=1
else
    GH_AUTHENTICATED=0
fi

ack_run() {
    local id="$1"
    flock -x 8
    jq --arg id "$id" '. + [$id] | unique' "$ACK_FILE" | atomic_write "$ACK_FILE"
    flock -u 8
}

# The menu folds matrix legs and reruns into one row per workflow and commit,
# so acknowledging a row hides every run represented by it.
ack_workflow_group() {
    local id="$1" run_ids
    mapfile -t run_ids < <(jq -r --arg id "$id" '
        . as $runs
        | ($runs[] | select((.databaseId | tostring) == $id)) as $run
        | ($run.headSha // ("run:" + ($run.databaseId | tostring))) as $sha
        | $runs[]
        | select(.repository == $run.repository)
        | select((.workflowName // "GitHub Actions") == ($run.workflowName // "GitHub Actions"))
        | select((.headSha // ("run:" + (.databaseId | tostring))) == $sha)
        | .databaseId
    ' <<<"$ALL_RUNS_JSON")
    for id in "${run_ids[@]}"; do
        [[ -n "$id" ]] && ack_run "$id"
    done
}

CUTOFF=$(( $(date +%s) - MAX_AGE_DAYS * 86400 ))

notify_run_transitions() {
    local ack_json tracked initialized run id repo workflow title conclusion status previous sha
    local now_iso start_events group all_terminal oldest_finished finished_epoch now_epoch payload
    ack_json=$(cat "$ACK_FILE")
    tracked=$(jq -c 'if type == "object" then . else {} end' "$WATCH_FILE")
    initialized=$(jq -r '._initialized // false' <<<"$tracked")
    now_iso=$(date -Is)

    # Migrate state from versions that notified per run. Already-finished
    # entries were announced; anything still running can still notify later.
    tracked=$(jq -c '
        if (._notifyVersion // 0) == 2 then .
        else
          with_entries(
            if (.key | startswith("_")) then .
            else .value |= (. + {notified: ((.state // "") | startswith("finished:"))})
            end
          )
          | ._notifyVersion = 2
        end
    ' <<<"$tracked")

    start_events='[]'

    while IFS= read -r run; do
        id=$(jq -r '.databaseId | tostring' <<<"$run")
        repo=$(jq -r '.repository // "unknown repository"' <<<"$run")
        workflow=$(jq -r '.workflowName // "GitHub Actions"' <<<"$run")
        title=$(jq -r '.displayTitle // .headBranch // "Workflow run"' <<<"$run")
        status=$(jq -r '.status // ""' <<<"$run")
        conclusion=$(jq -r '.conclusion // ""' <<<"$run")
        sha=$(jq -r '.headSha // ""' <<<"$run")

        if jq -e --arg id "$id" 'index($id) != null' <<<"$ack_json" >/dev/null; then
            tracked=$(jq --arg id "$id" 'del(.[$id])' <<<"$tracked")
            continue
        fi

        previous=$(jq -r --arg id "$id" '.[$id].state // ""' <<<"$tracked")

        if [[ -z "$previous" ]]; then
            if [[ -n "$conclusion" ]]; then
                # Discovered already finished: don't announce a start, just
                # queue it for the grouped result notification.
                tracked=$(jq --arg id "$id" --arg repo "$repo" --arg workflow "$workflow" \
                    --arg title "$title" --arg sha "$sha" --arg state "finished:$conclusion" --arg now "$now_iso" \
                    '.[$id] = {state: $state, repo: $repo, workflow: $workflow, title: $title, sha: $sha, seenAt: $now, finishedAt: $now, notified: false}' \
                    <<<"$tracked")
            else
                if [[ "$initialized" == "true" ]]; then
                    start_events=$(jq -cn --argjson events "$start_events" --arg id "$id" --arg repo "$repo" --arg sha "$sha" \
                        --arg workflow "$workflow" --arg title "$title" \
                        '$events + [{id: $id, repo: $repo, sha: $sha, workflow: $workflow, title: $title}]')
                fi
                tracked=$(jq --arg id "$id" --arg repo "$repo" --arg workflow "$workflow" \
                    --arg title "$title" --arg sha "$sha" --arg state "${status:-queued}" --arg now "$now_iso" \
                    '.[$id] = {state: $state, repo: $repo, workflow: $workflow, title: $title, sha: $sha, seenAt: $now, notified: false}' \
                    <<<"$tracked")
            fi
            continue
        fi

        if [[ -n "$conclusion" && "$previous" != finished:* ]]; then
            tracked=$(jq --arg id "$id" --arg state "finished:$conclusion" --arg sha "$sha" --arg now "$now_iso" \
                '.[$id] |= ((. // {}) + {state: $state, sha: $sha, seenAt: $now, finishedAt: $now})' \
                <<<"$tracked")
        elif [[ -n "$conclusion" ]]; then
            # Cached runs may have been fetched before headSha was requested;
            # keep it current so the grouped notification can find its peers.
            if [[ -n "$sha" ]]; then
                tracked=$(jq --arg id "$id" --arg sha "$sha" '.[$id].sha = $sha' <<<"$tracked")
            fi
        else
            # Queued/running transitions are quiet; they only affect grouping.
            tracked=$(jq --arg id "$id" --arg state "${status:-queued}" --arg sha "$sha" --arg now "$now_iso" \
                '.[$id] |= ((. // {}) + {state: $state, sha: $sha, seenAt: $now})' \
                <<<"$tracked")
        fi
    done < <(jq -c --argjson cutoff "$CUTOFF" 'map(select((.createdAt | fromdateiso8601) >= $cutoff))[]' <<<"$ALL_RUNS_JSON")

    # First ever poll: don't replay history, but keep watching runs that are
    # still in flight so their result is announced later.
    if [[ "$initialized" != "true" ]]; then
        tracked=$(jq -c '
            with_entries(
              if (.key | startswith("_")) then .
              else .value.notified = ((.value.state // "") | startswith("finished:"))
              end
            )
        ' <<<"$tracked")
    else
        # One grouped notification per commit when workflows start.
        while IFS= read -r payload; do
            notify_ci "$(jq -r '.repo' <<<"$payload")" "$(jq -r '.summary' <<<"$payload")" "$(jq -r '.body' <<<"$payload")"
        done < <(jq -c '
            group_by([.repo, (if .sha == "" then "run:" + .id else .sha end)])
            | .[]
            | . as $group
            | ($group | group_by(.workflow) | map(.[0])) as $workflows
            | {
                repo: $group[0].repo,
                summary: (
                  if ($workflows | length) == 1 then "\($workflows[0].workflow) started"
                  else "\($workflows | length) workflows started"
                  end
                ),
                body: (
                  (if ($workflows | length) == 1 then []
                   else [ $workflows[] | "• " + .workflow ]
                   end)
                  + [$group[0].title]
                  | join("\n")
                )
              }
        ' <<<"$start_events")

        # Finished workflows are grouped per commit too. Wait until every
        # workflow for that commit is done (or the grace period expires) so
        # parallel jobs produce one notification instead of one each.
        while IFS= read -r group; do
            repo=$(jq -r '.[0].repo' <<<"$group")
            sha=$(jq -r '.[0].sha' <<<"$group")
            [[ -z "$sha" ]] && continue

            all_terminal=$(jq -r --arg repo "$repo" --arg sha "$sha" '
                [ .[] | select(.repository == $repo and .headSha == $sha) ]
                | length > 0 and all(.conclusion != null and .conclusion != "")
            ' <<<"$ALL_RUNS_JSON")

            oldest_finished=$(jq -r '[.[].finishedAt // empty] | min // empty' <<<"$group")
            if [[ "$all_terminal" != "true" ]]; then
                [[ -z "$oldest_finished" ]] && continue
                finished_epoch=$(date -d "$oldest_finished" +%s)
                now_epoch=$(date +%s)
                (( now_epoch - finished_epoch >= NOTIFY_BATCH_GRACE )) || continue
            fi

            payload=$(jq -c '
                def state_name:
                  if . == "success" then "succeeded"
                  elif . == "failure" then "failed"
                  elif . == "cancelled" then "cancelled"
                  elif . == "timed_out" then "timed out"
                  elif . == "action_required" then "awaiting approval"
                  elif . == "startup_failure" then "failed to start"
                  elif . == "skipped" then "skipped"
                  elif . == "neutral" then "finished"
                  else (gsub("_"; " "))
                  end;

                # Matrix legs and reruns can produce several runs for the same
                # workflow on one commit. Fold them into a single result, with
                # the worst conclusion winning.
                def worst_conclusion:
                  . as $conclusions
                  | ($conclusions | unique) as $unique
                  | if ($unique | length) == 1 then $unique[0]
                    elif ($conclusions | index("failure")) then "failure"
                    elif ($conclusions | index("timed_out")) then "timed_out"
                    elif ($conclusions | index("startup_failure")) then "startup_failure"
                    elif ($conclusions | index("cancelled")) then "cancelled"
                    elif ($conclusions | index("action_required")) then "action_required"
                    else "neutral"
                    end;

                . as $group
                | [ $group[] | {id: .id, workflow: .workflow, title: .title, conclusion: (.state | sub("^finished:"; ""))} ] as $runs
                | ($runs
                   | group_by(.workflow)
                   | map(
                       . as $workflow_runs
                       | {
                           workflow: $workflow_runs[0].workflow,
                           ids: [$workflow_runs[].id],
                           conclusion: ($workflow_runs | map(.conclusion) | worst_conclusion)
                         }
                     )
                  ) as $workflows
                | ($workflows | map(.conclusion | state_name)) as $labels
                | ($labels | unique) as $unique
                | {
                    repo: $group[0].repo,
                    ids: [$workflows[].ids[]],
                    summary: (
                      if ($workflows | length) == 1 then "\($workflows[0].workflow) \($labels[0])"
                      elif ($unique | length) == 1 then "\($workflows | length) workflows \($unique[0])"
                      else "\($workflows | length) workflows finished"
                      end
                    ),
                    body: (
                      if ($workflows | length) == 1 then $group[0].title
                      else
                        ((if ($unique | length) == 1 then
                            [ $workflows[] | "• " + .workflow ]
                          else
                            [ $workflows[] | "• \(.workflow) — \(.conclusion | state_name)" ]
                          end)
                         + [$group[0].title]
                         | join("\n"))
                      end
                    )
                  }
            ' <<<"$group")

            notify_ci "$(jq -r '.repo' <<<"$payload")" "$(jq -r '.summary' <<<"$payload")" "$(jq -r '.body' <<<"$payload")"
            tracked=$(jq -c --argjson ids "$(jq -c '.ids' <<<"$payload")" \
                'reduce $ids[] as $id (. ; .[$id].notified = true)' <<<"$tracked")
        done < <(jq -c --argjson repos "$REPOS_JSON" '
            to_entries
            | map(select(.key | startswith("_") | not))
            | map(.value + {id: .key})
            | map(select(.repo as $repo | $repos | index($repo)))
            | map(select((.state // "") | startswith("finished:")))
            | map(select((.state // "") != "finished:cancelled"))
            | map(select(.notified != true))
            | group_by([.repo, .sha])
            | .[]
        ' <<<"$tracked")
    fi

    printf '%s\n' "$(jq '._initialized = true' <<<"$tracked")" | atomic_write "$WATCH_FILE"
}

summarize_status() {
    local ack_json filtered running failed success pending output
    ack_json=$(cat "$ACK_FILE")
    filtered=$(jq --argjson cutoff "$CUTOFF" --argjson ack "$ack_json" '
        map(select((.createdAt | fromdateiso8601) >= $cutoff))
        | map(select((.databaseId | tostring) as $id | ($ack | index($id)) == null))
        | group_by([.repository, (.workflowName // "GitHub Actions")])
        | map(
            . as $workflow_runs
            | ($workflow_runs | max_by(.createdAt)) as $latest
            | ($latest.headSha // ("run:" + ($latest.databaseId | tostring))) as $sha
            | ($workflow_runs
               | map(select((.headSha // ("run:" + (.databaseId | tostring))) == $sha))) as $runs
            # Ignore a cancelled matrix leg or rerun when the same workflow
            # also produced a real result on this commit.
            | ($runs | map(select(.conclusion != "cancelled"))) as $non_cancelled
            | ($non_cancelled | if length > 0 then . else $runs end) as $considered
            | ($considered | map(.status)) as $statuses
            | {
                repository: $latest.repository,
                state:
                  (if ($statuses | index("in_progress")) then "in_progress"
                   elif ($statuses | any(. == "queued" or . == "requested" or . == "waiting" or . == "pending")) then "pending"
                   elif ($considered | any(.conclusion == "failure" or .conclusion == "timed_out")) then "failed"
                   elif ($considered | any(.conclusion == "success")) then "success"
                   else "neutral"
                   end)
              }
          )
    ' <<<"$ALL_RUNS_JSON")

    running=$(jq '[.[] | select(.state == "in_progress")] | length' <<<"$filtered")
    failed=$(jq '[.[] | select(.state == "failed")] | length' <<<"$filtered")
    success=$(jq '[.[] | select(.state == "success")] | length' <<<"$filtered")
    pending=$(jq '[.[] | select(.state == "pending")] | length' <<<"$filtered")

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
        def state_label:
          if . == "success" then "SUCCESS"
          elif . == "failure" then "FAILURE"
          elif . == "timed_out" then "TIMED OUT"
          elif . == "cancelled" then "CANCELLED"
          elif . == "action_required" then "APPROVAL"
          elif . == "startup_failure" then "START FAIL"
          elif . == "in_progress" then "IN PROGRESS"
          elif . == "queued" then "QUEUED"
          elif . == "skipped" then "SKIPPED"
          elif . == "neutral" then "DONE"
          else ascii_upcase
          end;

        def state_icon:
          if . == "success" then "🟢"
          elif . == "failure" or . == "timed_out" or . == "startup_failure" then "🔴"
          elif . == "cancelled" then "⚪"
          elif . == "action_required" then "🟠"
          elif . == "in_progress" then "🟡"
          elif . == "queued" then "🔵"
          else "⚪"
          end;

        # Matrix legs and reruns on the same commit are one workflow result,
        # with the worst conclusion winning.
        def worst_conclusion:
          . as $conclusions
          | ($conclusions | unique) as $unique
          | if ($unique | length) == 1 then $unique[0]
            elif ($conclusions | index("failure")) then "failure"
            elif ($conclusions | index("timed_out")) then "timed_out"
            elif ($conclusions | index("startup_failure")) then "startup_failure"
            elif ($conclusions | index("cancelled")) then "cancelled"
            elif ($conclusions | index("action_required")) then "action_required"
            else "neutral"
            end;

        def age:
          (now - (.createdAt | fromdateiso8601)) as $seconds
          | if $seconds < 60 then "now"
            elif $seconds < 3600 then "\($seconds / 60 | floor)m"
            elif $seconds < 86400 then "\($seconds / 3600 | floor)h"
            else "\($seconds / 86400 | floor)d"
            end;

        def trim($limit):
          if (length) > $limit then .[0:$limit] + "…" else . end;

        map(select((.createdAt | fromdateiso8601) >= $cutoff))
        | map(select((.databaseId | tostring) as $id | ($ack | index($id)) == null))
        | group_by([.repository, (.workflowName // "GitHub Actions")])
        | map(
            . as $workflow_runs
            | ($workflow_runs | max_by(.createdAt)) as $latest
            | ($latest.headSha // ("run:" + ($latest.databaseId | tostring))) as $sha
            | ($workflow_runs
               | map(select((.headSha // ("run:" + (.databaseId | tostring))) == $sha))) as $runs
            # A cancelled leg should not make an otherwise successful matrix
            # look cancelled, so ignore cancelled runs when others exist.
            | ($runs | map(select(.conclusion != "cancelled"))) as $non_cancelled
            | ($non_cancelled | if length > 0 then . else $runs end) as $considered
            | ($considered | map(.status)) as $statuses
            | (if ($statuses | index("in_progress")) then "in_progress"
               elif ($statuses | any(. == "queued" or . == "requested" or . == "waiting" or . == "pending")) then "queued"
               else ($considered | map(.conclusion // "neutral") | worst_conclusion)
               end) as $state
            | ($considered
               | map(select(.conclusion == "failure" or .conclusion == "timed_out" or .conclusion == "startup_failure"))
               | if length > 0 then max_by(.createdAt)
                 elif ($considered | map(select(.status == "in_progress")) | length) > 0 then ($considered | map(select(.status == "in_progress")) | max_by(.createdAt))
                 else ($considered | max_by(.createdAt))
                 end) as $rep
            | {
                created: $latest.createdAt,
                state: $state,
                row: "\($state | state_icon) \($state | state_label) · \($latest.repository) · \($latest.workflowName // "GitHub Actions") · \(($latest.displayTitle // $latest.headBranch // "Workflow run") | trim(44)) · \($latest | age) | \($rep.databaseId)"
              }
          )
        | sort_by([(.state == "in_progress"), .created]) | reverse
        | .[].row
    ' <<<"$ALL_RUNS_JSON")

    if [[ -z "$menu_items" ]]; then
        if (( GH_AUTHENTICATED )); then
            notify_msg "No cached workflows" "A background refresh will fetch recent workflow runs."
        else
            report_missing_github_auth
        fi
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
        --prompt="Action: " \
        --background-color=1e1e1eff --text-color=cdd6f4ff --input-color=cdd6f4ff \
        --selection-color=585b70ff --selection-text-color=cdd6f4ff \
        --width=35 --lines=3 --horizontal-pad=12 --border-radius=10 2>/dev/null) || true

    case "$menu_action" in
        "Open in browser") [[ -n "$run_url" ]] && xdg-open "$run_url" 2>/dev/null || true ;;
        "Acknowledge (hide)")
            ack_workflow_group "$run_id"
            notify_msg "Workflow hidden" "Acknowledged the latest runs for this workflow."
            ;;
    esac
}

if (( ! GH_AUTHENTICATED )) && [[ "$ACTION" == "status" || "$ACTION" == "refresh" || "$ACTION" == "ack-all" ]]; then
    report_missing_github_auth
    STATUS_OUTPUT="🔒 GH login"
    printf '%s' "$STATUS_OUTPUT" | atomic_write "$OUTPUT_FILE"
    printf '%s' "$STATUS_OUTPUT"
    exit 0
fi

case "$ACTION" in
    refresh)
        # Keep the displayed snapshot while replacing caches under the lock.
        FORCE_REFRESH=1
        ;;
    status-menu|ack-menu)
        load_cached_runs
        show_status_menu
        ( nohup "$0" status >/dev/null 2>&1 </dev/null & )
        exit 0
        ;;
    open)
        load_cached_runs
        TARGET_URL=$(jq -r '
            group_by([.repository, (.workflowName // "GitHub Actions")])
            | map(
                . as $workflow_runs
                | ($workflow_runs | max_by(.createdAt)) as $latest
                | ($latest.headSha // ("run:" + ($latest.databaseId | tostring))) as $sha
                | ($workflow_runs
                   | map(select((.headSha // ("run:" + (.databaseId | tostring))) == $sha)))
              )
            | map(
                (map(select(.conclusion == "failure" or .conclusion == "timed_out")) | max_by(.createdAt))
                // (map(select(.status == "in_progress")) | max_by(.createdAt))
                // (map(select(.status != "completed")) | max_by(.createdAt))
                // empty
              )
            | sort_by(.createdAt) | last | .url // empty
        ' <<<"$ALL_RUNS_JSON")
        if [[ -n "$TARGET_URL" ]]; then
            xdg-open "$TARGET_URL" 2>/dev/null || true
        else
            FIRST_REPO=$(jq -r '.[0] // "skifli/nixos"' <<<"$REPOS_JSON")
            xdg-open "https://github.com/$FIRST_REPO/actions" 2>/dev/null || true
        fi
        ( nohup "$0" status >/dev/null 2>&1 </dev/null & )
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
            | select(.conclusion == "failure" or .conclusion == "timed_out")
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
