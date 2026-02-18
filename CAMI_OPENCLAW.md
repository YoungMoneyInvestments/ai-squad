# Cami (OpenClaw) in a squad pane

Cami is your OpenClaw agent. Squad doesn’t install or run her — it only sends the **launch command** you already use into that pane.

## If OpenClaw/Cami is already installed

You don’t need to install or onboard again. Just tell squad how you start Cami.

1. **Edit `config.json`** (not the example — your actual `~/ai-squad/config.json`).
2. Find the Cami agent and set **`launch`** to whatever you normally use to start her, for example:
   - **Terminal UI:** `openclaw tui`
   - **Gateway in foreground:** `openclaw gateway`
   - **Your own command** if you use a script, desktop app launcher, or something else.

When you run `squad up`, that pane will show that command; hit Enter and Cami starts the same way she always does. No second install.

## If you don’t have OpenClaw yet

Only then:

1. **Install:** `npm install -g openclaw@latest` (or `curl -fsSL https://openclaw.ai/install.sh | bash`).
2. **One-time setup:** `openclaw onboard --install-daemon` (or `openclaw onboard` and follow the wizard).
3. In `config.json`, set the Cami pane’s `launch` to `openclaw tui` (or the command you use to talk to your agent).

## Example config.json (Cami pane)

```json
{ "id": "cami", "name": "Cami (Open Claw)", "tmux": "squad:0.0", "launch": "openclaw tui" }
```

If you start Cami with a different command (e.g. from an app or another CLI), put that in `launch` instead. Squad only runs the string you give it; it never installs OpenClaw for you.
