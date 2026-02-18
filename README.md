# Squad CLI — Multi-Agent Orchestration with tmux

Run one command; Cami (Open Claw), Claude Code, Gemini, and Auto (Cursor) each get the same mission in their tmux pane. They read from a shared workspace, do work, write reports back. You aggregate and review. Optionally, agents hand off tasks to each other.

## How it works

- **File-based message bus**: Missions live in `workspace/missions/`. Each agent has `inbox/<agent_id>/` and `outbox/<agent_id>/`.
- **tmux**: The CLI uses `tmux send-keys` to paste a one-liner into each pane: “Mission at path X — read it, do it, save your report to path Y.”
- **No APIs required**: Each pane runs whatever interactive CLI you already use (Cursor, Open Claw, Gemini in terminal, etc.). They just need to read a file and write a file; you (or the AI in that pane) can do that.

**Does starting one CLI (Cursor, Claude Code, Gemini) pull in the others?** No. Starting Cursor (or any single app) does not start the other agents. You need each agent running in its own tmux pane. Then when you run `squad run "..."` from *any* terminal (inside or outside tmux), all panes in the squad session get the mission. So: run `squad up` to create/attach the session and see which pane is which; start each agent in its pane; from then on, every `squad run` notifies all of them.

**What triggers squad? (slash command?)** No. Squad is a **terminal CLI**. You run it from a shell: `squad up`, `squad run "mission"`, `squad status`, etc. Run those from any terminal (a 5th tmux pane, your main terminal, or inside one of the agent panes). There is no slash command inside Cursor/Gemini/Claude; the trigger is you typing the command.

**Free mode (no permission prompts):** When agents act on squad missions, they should run in “free” / non-interactive mode so they don’t block on permission prompts. Set a `launch` command per agent in `config.json`. Example: `gemini --yolo`, `cursor-agent -f`, `claude --dangerously-skip-permissions`. `squad up` will pre-fill each pane with that command so you can just hit Enter to start the agent.

## Setup

### 1. Tmux session and panes

**Easiest:** run `squad up`. It creates the `squad` tmux session (if needed), prints which pane is for which agent, then attaches you to it. In each pane, start the right AI (Cami, Claude Code, Gemini, Cursor). No need to remember pane numbers—the layout is in your config.

**Manual layout** (optional): create a 2×2 session yourself, e.g.:

```bash
tmux new-session -d -s squad
tmux split-window -t squad -h
tmux split-window -t squad -v
tmux select-pane -t squad:0.0
tmux split-window -t squad -v
```

Result: `squad:0.0`, `squad:0.1`, `squad:1.0`, `squad:1.1`. Match these to your `config.json` agents; then in each pane run the corresponding AI.

### 2. Config

```bash
cd ~/ai-squad
cp config.example.json config.json
```

Edit `config.json`: set `tmux_session`, each agent’s `tmux` pane (e.g. `squad:0.0`), and each agent’s `launch` command for free mode (e.g. `gemini --yolo`, `cursor-agent -f`, `claude --dangerously-skip-permissions`). `workspace` can stay as `~/ai-squad/workspace` or point elsewhere.

### 3. Run the CLI

Use the script directly (or add `~/ai-squad` to PATH and run `squad`):

```bash
python3 ~/ai-squad/squad run "Audit the auth module and suggest three fixes"
# or
echo "Refactor X and add tests" | python3 ~/ai-squad/squad run
python3 ~/ai-squad/squad run -f ~/mission.txt
```

## Commands

| Command | Purpose |
|--------|--------|
| `squad up` | Create or attach to the squad tmux session; print pane→agent map. Start each AI in its pane. |
| `squad run "task"` or `squad run -f file` | Create a mission, write to workspace, notify all panes via tmux. |
| `squad status [mission_id]` | List recent missions, or for one mission show which agents have reported. |
| `squad report <mission_id>` | Print all agents’ reports for that mission. |
| `squad handoff --from cami --to gemini "Implement the API"` | Write task into Gemini’s inbox and send a key to Gemini’s pane. |

## Runbook: Get everyone running and test

Cami runs on Claude Code (Open Claw) and is already in unhinged mode; you still need each agent in its own pane so they all receive missions. Use 4 panes (Cami, Claude Code, Gemini, Cursor) or 3 if you treat Cami as your only Claude—match your `config.json` to the panes you use.

**1. One-time setup**

```bash
cd ~/ai-squad
cp config.example.json config.json
# Edit config.json: tmux_session, each agent's tmux pane, and launch commands.
# Cami (Open Claw on Claude): set launch to whatever starts her, e.g. "claude".
```

**2. Bring up the squad**

```bash
python3 ~/ai-squad/squad up
```

You're attached to the `squad` tmux session. If the session was just created, each pane has its `launch` command typed; in each pane **hit Enter** to start that agent. If you attached to an existing session, run the printed launch command in each pane.

**3. Send a test mission (from another terminal)**

Open a **new terminal** (outside tmux, or a 5th pane):

```bash
python3 ~/ai-squad/squad test
```

It prints e.g. `Mission 20250217_143022 created and dispatched.` and `Check reports: squad status 20250217_143022`.

**4. In each agent pane**

Each pane gets a line like: `# Squad mission 20250217_143022 — read: …/inbox/cami/20250217_143022.txt`. In that pane (you or the AI): open that inbox path, do the one-liner (reply "Cami received." etc.), save that as the report to the outbox path given in the inbox.

**5. Check results**

```bash
python3 ~/ai-squad/squad status 20250217_143022
python3 ~/ai-squad/squad report 20250217_143022
```

**Recap:** `squad up` → Enter in each pane to start agents → from another terminal `squad test` → in each pane read inbox, write one line to outbox → `squad status <id>` and `squad report <id>`.

## Workflow

1. You: `squad run "Do xyz"`.
2. Each pane gets a line like: `# Squad mission 20250217_123456 — read: …/inbox/cami/20250217_123456.txt`.
3. In each pane, you (or the AI) open that path, read the mission and the report path, do the work, then save the report to the given outbox path.
4. You: `squad status 20250217_123456` to see who’s done, then `squad report 20250217_123456` to read everyone’s output.
5. For agent-to-agent: e.g. Cami’s report says “Gemini should implement X.” You run `squad handoff --from cami --to gemini "Implement X"`, and Gemini’s pane gets a new inbox file and a notification.

## Optional: same mission, different roles

You can refine the mission file by hand before the agents run: e.g. add “Cami: focus on security. Claude: focus on tests. Gemini: focus on API. Auto: focus on docs.” Then dispatch once; each agent reads the same file but follows their line.

## Requirements

- Python 3.9+
- tmux
- No extra pip packages (stdlib only)

## Troubleshooting

- **“Could not send to squad:0.0”**: Tmux session or pane doesn’t exist. Run `tmux list-panes -s` to see targets.
- **Agents don’t see missions**: They must actually open the path that’s pasted (or you paste the mission text yourself). The CLI only sends the *pointer* to the file.
- **Reports not showing**: Ensure each agent writes a file to `workspace/outbox/<agent_id>/<mission_id>.md` (the path is in their inbox file).
