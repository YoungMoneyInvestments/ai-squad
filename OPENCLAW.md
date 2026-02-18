# OpenClaw in a squad pane

Your OpenClaw agent runs in one pane. Squad doesn't install or run it — it only sends the **launch command** you already use into that pane.

## If OpenClaw is already installed

You don't need to install or onboard again. Just tell squad how you start your agent.

1. **Edit `config.json`** (your actual `~/ai-squad/config.json`).
2. Find the OpenClaw agent and set **`launch`** to whatever you normally use to start it, for example:
   - **Terminal UI:** `openclaw tui`
   - **Gateway in foreground:** `openclaw gateway`
   - **Your own command** if you use a script, desktop app launcher, or something else.

When you run `squad up`, that pane will show that command; hit Enter and your agent starts the same way it always does. No second install.

## If you don't have OpenClaw yet

Only then:

1. **Install:** `npm install -g openclaw@latest` (or `curl -fsSL https://openclaw.ai/install.sh | bash`).
2. **One-time setup:** `openclaw onboard --install-daemon` (or `openclaw onboard` and follow the wizard).
3. In `config.json`, set that pane's `launch` to `openclaw tui` (or the command you use to talk to your agent).

## Example config (OpenClaw pane)

```json
{ "id": "openclaw", "name": "OpenClaw", "tmux": "squad:0.0", "launch": "openclaw tui" }
```

If you start your agent with a different command (e.g. from an app or another CLI), put that in `launch` instead. Squad only runs the string you give it; it never installs OpenClaw for you.
