#!/usr/bin/env bash
set -Eeuo pipefail

# Replit provides the graphical display. Do not replace DISPLAY unless it is
# genuinely absent: doing so can disconnect Firefox from Replit's Output pane.
if [[ -z "${DISPLAY:-}" ]]; then
  echo "ERROR: DISPLAY is not set. Run this Repl as a graphical application." >&2
  exit 1
fi

browser="${FIREFOX_BIN:-firefox}"
if ! command -v "$browser" >/dev/null 2>&1; then
  echo "ERROR: Firefox was not found. Reload the Replit Nix environment." >&2
  exit 1
fi

start_url="${FIREFOX_START_URL:-https://github.com/valetzx}"
profile_dir="${FIREFOX_PROFILE_DIR:-$HOME/.cache/firefox-replit}"
mkdir -p "$profile_dir"

# Current Replit exposes the editor URL through REPLIT_DEV_DOMAIN and the
# published/custom domains through REPLIT_DOMAINS. Older REPL_ID/repl.co URLs
# are intentionally not used because that hosting scheme was retired.
if [[ -n "${REPLIT_DEV_DOMAIN:-}" ]]; then
  echo "Replit editor URL: https://${REPLIT_DEV_DOMAIN}"
elif [[ -n "${REPLIT_DOMAINS:-}" ]]; then
  echo "Replit app domain(s): ${REPLIT_DOMAINS}"
else
  echo "Replit domain: available from the App's Run/Output panel"
fi

echo "Starting Firefox at ${start_url}"
echo "VNC_PASSWORD is configured for external tooling: $([[ -n "${VNC_PASSWORD:-}" ]] && echo yes || echo no)"

firefox_args=(
  --no-remote
  --new-instance
  --profile "$profile_dir"
  --new-tab "$start_url"
)

cleanup() {
  if [[ -n "${firefox_pid:-}" ]] && kill -0 "$firefox_pid" 2>/dev/null; then
    kill "$firefox_pid" 2>/dev/null || true
    wait "$firefox_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

"$browser" "${firefox_args[@]}" >"$profile_dir/firefox.log" 2>&1 &
firefox_pid=$!

# Keep the Run process attached to Firefox. Do not sleep for a fixed duration
# or kill PID 1; both behaviors are unreliable in current Replit runtimes.
if wait "$firefox_pid"; then
  status=0
else
  status=$?
fi
if (( status != 0 )); then
  echo "Firefox exited with status ${status}; see ${profile_dir}/firefox.log" >&2
fi
exit "$status"
