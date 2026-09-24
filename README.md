# Firefox on Replit

This project launches Firefox in Replit's graphical **Output** pane. It is intended for interactive development and testing, not for hosting an unattended browser service.

## Run it on current Replit

1. Import or fork this repository into Replit.
2. Let Replit install the packages from [`replit.nix`](replit.nix), then use **Tools → Replit → Restart compute** (or reload the shell) if the packages are not available yet.
3. Press **Run**. The `.replit` configuration starts [`main.sh`](main.sh), which opens Firefox in the Output pane.
4. Optionally add these environment variables under **Tools → Secrets**:
   - `FIREFOX_START_URL`: URL to open, defaulting to `https://github.com/valetzx`.
   - `FIREFOX_PROFILE_DIR`: persistent Firefox profile location, defaulting to `$HOME/.cache/firefox-replit`.
   - `VNC_PASSWORD`: retained for external VNC tooling if you have configured such tooling separately. The launcher never prints the password.

The launcher uses `REPLIT_DEV_DOMAIN` or `REPLIT_DOMAINS` when displaying the current app domain. It does not construct a legacy `REPL_ID.id.repl.co` URL; `repl.co` hosting was retired in favor of Replit Deployments and current `replit.dev`/`replit.app` domains.

## Notes

- Firefox must run as a graphical Replit App so that Replit supplies `DISPLAY` and an Output pane. If the launcher reports that `DISPLAY` is missing, open the project in the Replit workspace rather than running it as a headless deployment.
- The **Run** process stays attached to Firefox and exits only when Firefox exits or the Repl is stopped. It no longer kills PID 1 or stops after a fixed 12-hour timeout.
- Firefox output is written to `$HOME/.cache/firefox-replit/firefox.log` by default.
- The old noVNC instructions have been removed because this repository does not include a VNC server or WebSocket proxy. Use Replit's Output pane for the supported graphical workflow, or configure and secure a separate VNC service yourself.

## Customizing the browser

For example, set a different start page in the Replit Shell before pressing **Run**:

```bash
export FIREFOX_START_URL="https://example.com"
```

For a persistent setting, add `FIREFOX_START_URL` as a Replit Secret or environment variable. Do not commit passwords, tokens, or other secrets to the repository.
