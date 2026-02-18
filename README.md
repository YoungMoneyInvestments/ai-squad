# Squad CLI — Make multiple AI agents work like a team (tmux + files)

You’ve got multiple agents (Claude Code, Gemini, Cursor/Auto, OpenClaw/Cami…) and a single human brain. **Squad** gives you a lightweight way to issue one mission, let each agent do work in their own terminal, and then **collect results back into one color-coded stream**.

This is not another “agent framework.” It’s a pragmatic operator tool:

- **No new APIs**
- **No plugins**
- **No vendor lock-in**
- **Just tmux + a shared folder + a tiny CLI**

## What you get (features + benefits)

- **Broadcast missions**: One command sends the same mission pointer to every agent pane.
- **Targeted messages**: Nudge one agent without spamming the whole team (`squad send` or `@agent …` in chat).
- **One command-center prompt**: `squad chat` lets you keep typing tasks repeatedly (broadcast or targeted) without switching panes.
- **Color-coded aggregation**: `squad watch` streams reports into your main window, color-coded by agent, so you can triage fast.
- **Safe by default**: Your local `config.json` and `workspace/` (missions + reports) are **gitignored**.
- **Agent-agnostic**: Works with any interactive CLI that can read a file and write a file.

## How it works (mental model)

Squad is basically a file-based message bus with tmux notifications:

```
You (command center)          Agents (tmux panes)                   Back to you
---------------------         --------------------                  ----------
squad run "mission"  ───▶     pane gets: inbox path     ───▶        agent writes report
 mission written to disk       agent reads mission                  outbox/*.md appears
 per-agent inbox created       agent does work                      squad watch/report prints
 tmux send-keys notification
```

Each mission creates:

- `workspace/missions/<MISSION_ID>_mission.md`
- `workspace/inbox/<agent_id>/<MISSION_ID>.txt` (contains the mission path + report path)
- `workspace/outbox/<agent_id>/<MISSION_ID>.md` (agent writes this when done)

## Quick start

```bash
git clone https://github.com/YoungMoneyInvestments/ai-squad.git ~/ai-squad
cd ~/ai-squad
python3 squad setup          # creates config.json (if missing) + workspace dirs
${EDITOR:-nano} config.json  # set tmux panes + launch commands
python3 squad up             # create/attach tmux session; start each agent in its pane

# From another terminal (your command center):
python3 squad test
python3 squad watch 20250217_143022
```

If you add `~/ai-squad` to your `PATH`, you can run commands as `squad ...` instead of `python3 squad ...`.

## Commands (operator’s cheat sheet)

| Command | Use it for |
|--------|------------|
| `squad setup` | First run: create `config.json` (if missing) + workspace dirs. |
| `squad doctor` | Sanity-check tmux, config, session, panes, workspace permissions. |
| `squad up` | Create/attach the tmux session and print pane→agent map. |
| `squad run "task"` / `squad run -f file` | Broadcast a mission to all agents. |
| `squad test` | Smoke test the pipeline (agents write “received”). |
| `squad send <agent_id> "msg"` | Message one agent only (inbox + tmux notify). |
| `squad handoff --from X --to Y "task"` | Formal “agent A → agent B” delegation. |
| `squad status [mission_id]` | Who’s done vs pending (color-coded). |
| `squad report <mission_id>` | Print all reports for one mission (color-coded). |
| `squad watch <mission_id>` | Stream reports as they arrive (color-coded). |
| `squad chat` | Interactive command center: broadcast by default; `@agent …` targets one. |

Use `--no-color` with `status`, `report`, or `watch` (or set `NO_COLOR=1`) for plain output.

## Setup

### 1) Run setup (creates config + workspace)

```bash
cd ~/ai-squad
python3 squad setup
```

### 2) Edit `config.json`

| Key | Meaning |
|-----|--------|
| `tmux_session` | Tmux session name (default: `squad`). |
| `workspace` | Where missions/inbox/outbox live (default: `~/ai-squad/workspace`). |
| `agents` | List of `{ id, name, tmux, launch }`. `tmux` targets are panes like `squad:0.0` … `squad:0.3` (one window, four panes). `launch` is what you run in that pane (e.g. `openclaw tui`, `claude --dangerously-skip-permissions`, `gemini --yolo`, `cursor-agent -f`). |

### 3) Start the squad session

```bash
python3 squad up
```

In each pane, run the printed `launch` command (or just hit Enter if it’s already typed). Use **Ctrl+b → arrow keys** to switch panes.

### 4) Validate (optional but useful)

```bash
python3 squad doctor
```

## Runbook: your first real mission

1. `python3 squad up` (start agents in their panes)
2. From your command center terminal:
   - `python3 squad run "Do X, each of you focus on a different angle."`
   - or: `python3 squad run -f examples/example-mission.md`
3. Watch results:
   - `python3 squad watch <MISSION_ID>` (best UX)
   - or: `python3 squad status <MISSION_ID>` then `python3 squad report <MISSION_ID>`

## Chat mode: one pane to message all (repeatedly)

Run:

```bash
python3 squad chat
```

Then:

- Type a line → broadcasts to all agents.
- `@gemini do the API` → messages only Gemini.
- `/watch <id>` → stream reports here.
- `/quit` → exit.

## Color-coded reports (why it matters)

When you’re running 3–6 agents at once, raw output becomes noise. Squad makes it scannable:

- `squad watch <id>` prints each agent’s report as it arrives, with a **colored header per agent**.
- `squad status <id>` prints “done” vs “pending” with **status colors**.

## Privacy & safety

This repo is designed to be shareable without leaking your stuff:

- **Not committed (gitignored):** `config.json`, `workspace/`, `.env*`, `.claude/`, `secrets/`, keys, etc.
- **Committed:** `config.example.json` (template), `squad` script, docs, examples.

## Run from anywhere

Add the repo to your PATH:

```bash
export PATH=\"$HOME/ai-squad:$PATH\"   # put in ~/.zshrc or ~/.bashrc
```

Or symlink:

```bash
ln -s \"$HOME/ai-squad/squad\" /usr/local/bin/squad   # or ~/bin/squad
```

## Requirements

- Python 3.9+
- tmux
- Your agent CLIs of choice (Claude Code, Gemini CLI, Cursor agent, OpenClaw, etc.)

## Troubleshooting (common operator mistakes)

- **Wrong tmux targets:** Use panes in a single window: `squad:0.0`, `squad:0.1`, `squad:0.2`, `squad:0.3`. (If you use `squad:1.0` you’re targeting *window 1*, not “row 2”.)
- **Agents “didn’t get it”:** The CLI sends a pointer (path) into the pane. The agent (or you) must open that inbox file and follow it.
- **Reports missing:** The report path is in the inbox file. The outbox filename must match the mission ID.

## Cami (OpenClaw)

If you want one pane to be “Cami” via OpenClaw, set that agent’s `launch` to `openclaw tui` (or whatever command you use). See [CAMI_OPENCLAW.md](CAMI_OPENCLAW.md).
