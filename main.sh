#!/usr/bin/env bash
set -Eeuo pipefail

# Replit provides the graphical display. Do not replace DISPLAY unless it is
# genuinely absent: doing so can disconnect the browser from the Output pane.
if [[ -z "${DISPLAY:-}" ]]; then
  echo "ERROR: DISPLAY is not set. Run this Repl as a graphical application." >&2
  exit 1
fi

# Snapchat Web currently supports Chromium/Chrome-family browsers, not Firefox.
# Override BROWSER_BIN if you want to use a different browser.
browser="${BROWSER_BIN:-chromium}"
if ! command -v "$browser" >/dev/null 2>&1; then
  echo "ERROR: Browser '$browser' was not found. Reload the Replit Nix environment." >&2
  exit 1
fi

start_url="${BROWSER_START_URL:-https://web.snapchat.com}"
profile_dir="${BROWSER_PROFILE_DIR:-$HOME/.cache/firefox-replit}"
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

echo "Starting ${browser} at ${start_url}"
echo "VNC_PASSWORD is configured for external tooling: $([[ -n "${VNC_PASSWORD:-}" ]] && echo yes || echo no)"

case "$(basename "$browser")" in
  chromium|chromium-browser|google-chrome|google-chrome-stable)
    browser_args=(
      --no-sandbox
      --disable-dev-shm-usage
      --user-data-dir="$profile_dir"
      --new-window
      "$start_url"
    )
    ;;
  *)
    browser_args=(
      --no-remote
      --new-instance
      --profile "$profile_dir"
      --new-tab "$start_url"
    )
    ;;
esac

cleanup() {
  if [[ -n "${browser_pid:-}" ]] && kill -0 "$browser_pid" 2>/dev/null; then
    kill "$browser_pid" 2>/dev/null || true
    wait "$browser_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

"$browser" "${browser_args[@]}" >"$profile_dir/browser.log" 2>&1 &
browser_pid=$!

# Keep the Run process attached to the browser. Do not sleep for a fixed
# duration or kill PID 1; both behaviors are unreliable in current Replit.
if wait "$browser_pid"; then
  status=0
else
  status=$?
fi
if (( status != 0 )); then
  echo "Browser exited with status ${status}; see ${profile_dir}/browser.log" >&2
fi
exit "$status"
