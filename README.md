# Squad CLI — Multi-Agent Orchestration with tmux

Run one command; Cami (Open Claw), Claude Code, Gemini, and Auto (Cursor) each get the same mission in their tmux pane. They read from a shared workspace, do work, write reports back. You aggregate and review in one window, color-coded by agent.

## Quick start

```bash
git clone <this-repo-url> ~/ai-squad
cd ~/ai-squad
python3 squad setup          # copies config.example.json → config.json, creates workspace
# Edit config.json with your tmux pane IDs and launch commands for each agent
python3 squad up             # create/attach tmux session; in each pane, hit Enter to start that agent
# From another terminal:
python3 squad run "Your mission for everyone"
python3 squad watch 20250217_143022   # stream color-coded reports as they arrive
```

[Add the repo to your PATH](#run-from-anywhere) to use `squad` from any directory.

## Table of contents

- [How it works](#how-it-works)
- [Setup](#setup)
- [Commands](#commands)
- [Runbook: first mission](#runbook-first-mission)
- [Chat mode: one pane to message all](#chat-mode-one-pane-to-message-all)
- [Color-coded reports](#color-coded-reports)
- [Run from anywhere](#run-from-anywhere)
- [Requirements](#requirements)
- [Troubleshooting](#troubleshooting)
- [Cami (OpenClaw)](#cami-openclaw)

## How it works

- **File-based message bus**: Missions live in `workspace/missions/`. Each agent has `inbox/<agent_id>/` and `outbox/<agent_id>/`.
- **tmux**: The CLI uses `tmux send-keys` to paste a one-liner into each pane: "Mission at path X — read it, do it, save your report to path Y."
- **No APIs required**: Each pane runs whatever interactive CLI you already use (Cursor, Open Claw, Gemini, etc.). They read a file and write a file; you (or the AI in that pane) do the rest.

**Does starting one CLI pull in the others?** No. Each agent must be running in its own tmux pane. Run `squad up` to create/attach the session, start each agent in its pane, then from any terminal `squad run "..."` notifies all of them.

**Free mode:** Set a `launch` command per agent in `config.json` (e.g. `gemini --yolo`, `cursor-agent -f`, `claude --dangerously-skip-permissions`, `openclaw tui` for Cami) so they don’t block on permission prompts. `squad up` pre-fills each pane with that command.

## Setup

### 1. One-time: config and workspace

```bash
cd ~/ai-squad
python3 squad setup
```

This copies `config.example.json` → `config.json` (if missing) and creates the workspace directories. Then edit `config.json`:

| Key | Meaning |
|-----|--------|
| `tmux_session` | Tmux session name (e.g. `squad`). |
| `workspace` | Path for missions, inbox, outbox (e.g. `~/ai-squad/workspace`). |
| `agents` | List of `{ "id", "name", "tmux", "launch" }`. Use pane IDs like `squad:0.0` … `squad:0.3` (one window, four panes). `launch` is the command run in that pane (e.g. `openclaw tui`, `claude --dangerously-skip-permissions`, `gemini --yolo`, `cursor-agent -f`). |

See [CAMI_OPENCLAW.md](CAMI_OPENCLAW.md) if you use OpenClaw in one pane.

### 2. Tmux session and panes

Run `squad up`. It creates the `squad` tmux session (if needed), prints which pane is for which agent, then attaches you. In each pane, run the printed launch command (or hit Enter if it’s already there). Use **Ctrl+b** then **arrow keys** to switch panes.

### 3. Validate (optional)

```bash
python3 squad doctor
```

Checks that config is valid, tmux is installed, and the squad session and panes exist.

## Commands

| Command | Purpose |
|--------|--------|
| `squad setup` | Copy example config → config.json (if missing) and create workspace dirs. |
| `squad doctor` | Validate config, tmux, and session/panes. |
| `squad up` | Create or attach to the squad tmux session; print pane→agent map. |
| `squad run "task"` or `squad run -f file` | Create a mission and notify all panes. |
| `squad test` | Dispatch a smoke-test mission. |
| `squad status [mission_id]` | List missions or show who has reported (color-coded). |
| `squad report <mission_id>` | Print all agents’ reports (color-coded). |
| `squad watch <mission_id>` | Stream reports into this window as they arrive (color-coded). |
| `squad chat` | Interactive: type to broadcast; `@agent message` to message one agent. |
| `squad send <agent_id> "message"` | Send a message to one agent only. |
| `squad handoff --from X --to Y "task"` | Put a task in Y’s inbox and notify Y’s pane. |

Use `--no-color` with `report`, `status`, or `watch` to disable colors. Set `NO_COLOR=1` in the environment for the same effect.

## Runbook: first mission

1. **Setup:** `squad setup` → edit `config.json` → `squad up` → start each agent in its pane (Enter).
2. **From another terminal:** `squad test` → note the mission ID printed.
3. **In each agent pane:** Open the inbox path that was pasted, do the one-liner, save the report to the outbox path from the inbox.
4. **Check:** `squad status <id>` then `squad report <id>` (or `squad watch <id>` to stream as they arrive).

## Chat mode: one pane to message all

Run `squad chat` in a dedicated terminal. You get a `squad>` prompt. Type a line and Enter to **broadcast to all agents**. Type **`@agent_id message`** (e.g. `@gemini do the API`) to message only that agent. Use **`/status`**, **`/report <id>`**, **`/watch <id>`**, **`/quit`** without leaving chat.

## Color-coded reports

- **`squad report <id>`** and **`squad watch <id>`** print each agent’s output with a colored header (Cami=cyan, Claude=magenta, Gemini=green, Auto=blue).
- **`squad status <id>`** shows agent names in green (done) or dim yellow (pending).

## Run from anywhere

Add the repo to your PATH so you can run `squad` from any directory:

```bash
# Bash/Zsh: add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/ai-squad:$PATH"
# Then:
squad up
squad run "Mission here"
```

Or symlink the script:

```bash
ln -s "$HOME/ai-squad/squad" /usr/local/bin/squad   # or ~/bin/squad
```

## Requirements

- Python 3.9+
- tmux
- No extra pip packages (stdlib only)

## Troubleshooting

- **"Could not send to squad:0.0"**: Tmux session or pane doesn’t exist. Run `tmux list-panes -s` to see targets. Use **`squad:0.0`**, **`squad:0.1`**, **`squad:0.2`**, **`squad:0.3`** (one window, four panes).
- **Agents don’t see missions**: They must open the path that’s pasted; the CLI only sends the pointer.
- **Reports not showing**: Each agent must write to `workspace/outbox/<agent_id>/<mission_id>.md` (path is in the inbox file).
- **Config not found**: Run `squad setup` or `cp config.example.json config.json` and edit.

## Cami (OpenClaw)

If one pane runs OpenClaw (Cami), set that agent’s `launch` to `openclaw tui` (or whatever command you use). See [CAMI_OPENCLAW.md](CAMI_OPENCLAW.md) for details. No need to reinstall OpenClaw if you already have it.
