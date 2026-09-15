#!/usr/bin/env bash
# shared-state-lib.sh
# Helpers for properly writing single-file shared state (e.g., todo.json,
# anki-pomodoro.state) that is on an NFS mount.
#
# Source from a script with:  . "$HOME/.local/bin/shared-state-lib.sh"
# The library is deployed alongside the other scripts into ~/.local/bin.
#
# Backups are created as "<file>.bak.<N>" for N in 1..STATE_BACKUPS, where
# .bak.1 is the newest backup and higher N are older.

# Maximum number of rotating backups.
: "${STATE_BACKUPS:=3}"

state_real() {
    local file="$1"
    if [ -L "$file" ]; then readlink -f "$file"; else printf '%s\n' "$file"; fi
}

state_backup_name() {
    local target="$1" slot="$2"
    printf '%s.bak.%s\n' "$target" "$slot"
}

# Atomic commit of a new file over an existing state file.
# Usage: state_commit <path> <tmp_file_with_new_content>
# - Rotates a backup of the current good version first.
# - Preserves a leading symlink by writing through to its real target.
# - Renames the temp file atomically over the target.
state_commit() {
    local file="$1" tmp="$2"
    local dir target slot
    dir=$(dirname "$file")

    [ -f "$tmp" ] || return 1
    mkdir -p "$dir" 2>/dev/null || return 1

    target=$(state_real "$file")

    # Rotate backups of the current good version (if any): shift each backup up
    # by one slot, then the new file becomes .bak.1.
    if [ -f "$target" ]; then
        for slot in $(seq "$STATE_BACKUPS" -1 1); do
            if [ -f "$(state_backup_name "$target" "$slot")" ]; then
                local next
                next=$((slot + 1))
                [ "$next" -le "$STATE_BACKUPS" ] && \
                    mv -f "$(state_backup_name "$target" "$slot")" \
                          "$(state_backup_name "$target" "$next")" 2>/dev/null || true
            fi
        done
        cp -f "$target" "$(state_backup_name "$target" 1)" 2>/dev/null || true
    fi

    if ! mv -f "$tmp" "$target" 2>/dev/null; then
        rm -f "$tmp" 2>/dev/null || true
        return 1
    fi

    state_autocommit "$target"
    return 0
}

# If a commit-and-push is configured for the state file's git work tree, stage
# and commit just that file after every successful write. Controlled via
# STATE_COMMIT_AUTO (1/0, default 1) and STATE_COMMIT_NAME (e.g. "ami <ami@pifi>",
# default empty -> use repo/user config). Only acts when the file is inside a
# git work tree; just skips otherwise.
# Usage: state_autocommit <path>
state_autocommit() {
    local file="$1" top
    [ "${STATE_COMMIT_AUTO:-1}" = "1" ] || return 0
    [ -f "$file" ] || return 0

    # Resolve to the repo top-level; skip if not inside a git work tree.
    top=$(cd "$(dirname "$file")" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null) || return 0

    # Include a couple of neighboring .bak files and this file relative to root.
    local rel
    rel=$(git -C "$top" ls-files --error-unmatch "$file" 2>/dev/null) && {
        git -C "$top" add -A -- "$rel" 2>/dev/null || true
    }

    # Only commit if there is something staged (i.e., a real change happened).
    if ! git -C "$top" diff --cached --quiet 2>/dev/null; then
        if [ -n "${STATE_COMMIT_NAME:-}" ]; then
            git -C "$top" \
                -c "user.name=${STATE_COMMIT_NAME%% *}" \
                -c "user.email=${STATE_COMMIT_NAME##* }" \
                commit -m "state: auto-commit $(basename "$file")" --quiet >/dev/null 2>&1 || true
        else
            git -C "$top" commit -m "state: auto-commit $(basename "$file")" --quiet >/dev/null 2>&1 || true
        fi
    fi
    return 0
}

# Print the newest valid JSON array state (live file or backups). Returns 0 if
# a valid array exists, 1 otherwise. The caller can redirect to a tmp file and
# state_commit to restore.
state_json_array() {
    local file="$1" slot backup
    local target
    target=$(state_real "$file")

    if [ -f "$target" ] && jq -e 'type == "array"' "$target" >/dev/null 2>&1; then
        cat "$target"
        return 0
    fi

    for slot in $(seq 1 "$STATE_BACKUPS"); do
        backup=$(state_backup_name "$target" "$slot")
        if [ -f "$backup" ] && jq -e 'type == "array"' "$backup" >/dev/null 2>&1; then
            cat "$backup"
            return 0
        fi
    done
    return 1
}

# Print the newest valid content matching <regex> (live file or backups).
# Returns 0 on success, 1 otherwise.
state_validated_content() {
    local file="$1" regex="$2" slot backup
    local target
    target=$(state_real "$file")

    if [ -f "$target" ] && grep -qE "$regex" "$target" 2>/dev/null; then
        cat "$target"
        return 0
    fi

    for slot in $(seq 1 "$STATE_BACKUPS"); do
        backup=$(state_backup_name "$target" "$slot")
        if [ -f "$backup" ] && grep -qE "$regex" "$backup" 2>/dev/null; then
            cat "$backup"
            return 0
        fi
    done
    return 1
}
