#!/usr/bin/env bash
set -Eeuo pipefail

if (($# < 2)); then
  echo "Usage: $0 <account/cache> <command> [args...]" >&2
  exit 2
fi

cache="$1"
shift
if [[ "${1:-}" == "--" ]]; then
  shift
fi
if (($# == 0)); then
  echo "Missing build command." >&2
  exit 2
fi

temporary_dir="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
before_paths="$(mktemp "$temporary_dir/xilo-before.XXXXXX")"
after_paths="$(mktemp "$temporary_dir/xilo-after.XXXXXX")"
new_paths="$(mktemp "$temporary_dir/xilo-new.XXXXXX")"
watch_log="$(mktemp "$temporary_dir/xilo-watch.XXXXXX")"
nix path-info --all | LC_ALL=C sort -u > "$before_paths"

push_enabled=false
if [[ "${GITHUB_REF:-}" == "refs/heads/main" ]]; then
  push_enabled=true
fi

watch_pid=""
if [[ "$push_enabled" == true ]]; then
  xilo watch "$cache" > "$watch_log" 2>&1 &
  watch_pid=$!
  sleep 1
  if ! kill -0 "$watch_pid" 2>/dev/null; then
    wait "$watch_pid" || true
    watch_pid=""
    echo "Xilo watcher exited during startup; the end-of-build catch-up push will retry all new paths." >&2
    cat "$watch_log" >&2
  fi
fi

stop_watcher() {
  if [[ -n "$watch_pid" ]]; then
    kill -TERM "$watch_pid" 2>/dev/null || true
    wait "$watch_pid" 2>/dev/null || true
    watch_pid=""
  fi
}

finish() {
  status=$?
  trap - EXIT INT TERM
  stop_watcher

  if [[ "$push_enabled" == true ]]; then
    if nix path-info --all | LC_ALL=C sort -u > "$after_paths"; then
      if comm -13 "$before_paths" "$after_paths" > "$new_paths.raw"; then
        grep -Ev -- '(-source|\.drv)$' "$new_paths.raw" > "$new_paths" || true
        if [[ -s "$new_paths" ]]; then
          pushed=false
          for attempt in 1 2 3 4 5; do
            if xilo push "$cache" - < "$new_paths"; then
              pushed=true
              break
            fi
            if [[ "$attempt" -eq 5 ]]; then
              echo "Xilo catch-up push failed after $attempt attempts." >&2
              break
            fi
            delay=$((5 * (2 ** (attempt - 1))))
            echo "Xilo catch-up push failed (attempt $attempt/5); retrying in ${delay}s." >&2
            sleep "$delay"
          done
          if [[ "$pushed" != true && "$status" -eq 0 ]]; then
            status=1
          fi
        else
          echo "No new cacheable Nix store paths to push."
        fi
      else
        echo "Could not compare Nix store paths for the catch-up push." >&2
        [[ "$status" -ne 0 ]] || status=1
      fi
    else
      echo "Could not list Nix store paths for the catch-up push." >&2
      [[ "$status" -ne 0 ]] || status=1
    fi
    if [[ -s "$watch_log" ]]; then
      cat "$watch_log"
    fi
  fi

  rm -f "$before_paths" "$after_paths" "$new_paths" "$new_paths.raw" "$watch_log"
  exit "$status"
}

trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

build_status=1
build_attempts=5
for ((attempt = 1; attempt <= build_attempts; attempt++)); do
  echo "Build attempt $attempt/$build_attempts: $*"
  if [[ "$attempt" -eq "$build_attempts" && "${1:-}" == "nix" && "${2:-}" == "build" ]]; then
    echo "Final attempt enables Nix fallback builds for failed substitutes."
    if "$@" --fallback; then
      build_status=0
      break
    fi
  elif "$@"; then
    build_status=0
    break
  fi
  if [[ "$attempt" -eq "$build_attempts" ]]; then
    echo "Build failed after $attempt attempts; preserving and pushing completed store paths." >&2
    break
  fi
  delay=$((15 * (2 ** (attempt - 1))))
  (( delay > 120 )) && delay=120
  echo "Build failed (attempt $attempt/$build_attempts); retrying in ${delay}s." >&2
  sleep "$delay"
done

exit "$build_status"
