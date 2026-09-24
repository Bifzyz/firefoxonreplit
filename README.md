# Snapchat Web on Replit

This project launches a Chromium-based browser in Replit's graphical **Output** pane and opens Snapchat Web. Snapchat Web currently supports Chromium/Chrome-family browsers; Firefox may show a browser-unsupported message.

## Run it on current Replit

1. Import or fork this repository into Replit.
2. Let Replit install the packages from [`replit.nix`](replit.nix), then use **Tools → Replit → Restart compute** (or reload the shell) if the packages are not available yet.
3. Press **Run**. The `.replit` configuration starts [`main.sh`](main.sh), which opens `https://web.snapchat.com` in Chromium in the Output pane.
4. Sign in to Snapchat in the browser window. If Snapchat asks for camera or microphone access, allow the permissions for `web.snapchat.com`.

The launcher supports these environment variables:

- `BROWSER_START_URL`: URL to open, defaulting to `https://web.snapchat.com`.
- `BROWSER_BIN`: browser executable to use, defaulting to `chromium`. Set it to `firefox` only for sites that support Firefox.
- `BROWSER_PROFILE_DIR`: persistent Chromium profile location, defaulting to `$HOME/.cache/firefox-replit`.
- `VNC_PASSWORD`: retained for external VNC tooling if you have configured such tooling separately. The launcher never prints the password.

The launcher uses `REPLIT_DEV_DOMAIN` or `REPLIT_DOMAINS` when displaying the current app domain. It does not construct a legacy `REPL_ID.id.repl.co` URL; `repl.co` hosting was retired in favor of Replit Deployments and current `replit.dev`/`replit.app` domains.

## Snapchat Web limitations on Replit

- Snapchat Web needs a computer browser and may require camera, microphone, and notification permissions.
- Replit's graphical Output pane must provide `DISPLAY`; this setup is not a headless deployment.
- Camera and microphone access depends on whether the Replit graphical environment exposes usable devices. Text chat and other browser features can work even when device access is unavailable.
- Keep the Replit project private and do not commit Snapchat credentials, session data, or passwords.
- The **Run** process stays attached to the browser and exits only when the browser exits or the Repl is stopped. It does not kill PID 1 or stop after a fixed timeout.

## Customizing the browser

To open another URL, set the variable in the Replit Shell before pressing **Run**:

```bash
export BROWSER_START_URL="https://example.com"
```

For a persistent setting, add `BROWSER_START_URL` as a Replit Secret or environment variable. Do not commit passwords, tokens, or other secrets to the repository.

The old noVNC instructions were removed because this repository does not include a VNC server or WebSocket proxy. Use Replit's Output pane for the supported graphical workflow, or configure and secure a separate VNC service yourself.
