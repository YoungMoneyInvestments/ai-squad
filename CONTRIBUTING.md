# Contributing to ai-squad

Thanks for considering contributing.

## How to contribute

- **Bug reports and feature ideas:** Open a GitHub Issue on the repository. Describe what you expected and what happened (or what you’d like to see).
- **Code or docs:** Fork the repo, make your changes, then open a Pull Request. Keep changes focused and the CLI backward-compatible where possible.

## What to touch

- **Safe to edit:** `squad`, `config.example.json`, `README.md`, `OPENCLAW.md`, `CONTRIBUTING.md`, files in `examples/`.
- **Do not commit:** `config.json` (user config), anything under `workspace/` (missions and reports). These are in `.gitignore`.

## Running locally

```bash
cd ~/ai-squad
python3 squad setup   # if needed
python3 squad doctor  # sanity check
python3 squad --help
```

## Code style

- Python: follow PEP 8; the script stays single-file and stdlib-only.
- Docs: clear, minimal steps; assume a reader has tmux and at least one agent CLI installed.
