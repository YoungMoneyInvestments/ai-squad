#!/usr/bin/env bash
# Create or attach to tmux session "squad" with 4 panes (2x2).
# Run this once; then start Cami / Claude / Gemini / Auto in each pane.

set -e
SESSION="squad"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach-session -t "$SESSION"
fi

tmux new-session -d -s "$SESSION"
tmux split-window -t "$SESSION" -h
tmux split-window -t "$SESSION" -v
tmux select-pane -t "$SESSION:0.0"
tmux split-window -t "$SESSION" -v

# Optional: send a one-line reminder to each pane
for pane in 0.0 0.1 1.0 1.1; do
  tmux send-keys -t "$SESSION:$pane" "# Squad pane $pane — run your AI here" Enter
done

exec tmux attach-session -t "$SESSION"
