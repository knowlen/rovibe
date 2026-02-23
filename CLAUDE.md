# rovibe — Agent Context

## What you are doing

You are implementing **rovibe**: a CLI toolkit that provisions OS-level isolated
identities for AI coding agents. The core primitive is an OS user with a restricted
PATH and a read-only symlink mirror of a project. The kernel enforces the isolation
— not prompts, not tool settings.

This is a Bash-only project. Six scripts + one installer. No Python packages, no
Node, no dependencies beyond what is already installed on the machine.

## Repository structure

```
rovibe/
├── create-agent
├── assign-reviewer
├── unassign-reviewer
├── sync-mirror
├── launch-reviewer
├── list-reviewers
└── install.sh
```

Scripts are installed to `/usr/local/bin/`. All must work on both Linux (Arch) and
macOS. Platform branching is done via `uname -s` inside each script.

## Code standards

- `#!/usr/bin/env bash` shebang on every script
- `set -euo pipefail` at the top of every script
- Prefix all stdout messages with `[scriptname] ` (e.g. `[create-agent] Creating user...`)
- All errors go to stderr: `echo "ERROR: $*" >&2; exit 1`
- Every script that modifies system state must be idempotent
- Syntax-check every script with `bash -n` before considering it done
- No external dependencies beyond the allowlisted binaries in `/opt/agents/bin/`
  plus standard root-level tools (`useradd`, `groupadd`, `install`, etc.)

## Constraints

- Do not install any packages (apt, pacman, brew, pip, npm) at any point
- Do not create git commits or push anything to remote
- Do not modify scripts after they are installed to `/usr/local/bin/` unless you
  have found and can describe a genuine bug — state the bug clearly before patching
- If `fswatch` is not installed on this machine, note it and continue — do not
  install it
- Work as root / via sudo wherever system operations require it

## How to handle failures

If any step fails, stop. Do not attempt to work around a failure silently or
proceed to the next step. Report:
1. The exact command that failed
2. The full error output
3. Your diagnosis of the cause

Do not guess at fixes and re-run in a loop. Diagnose first, state the fix, then
apply it once.

## What done looks like

The implementation is complete when:
1. All 6 scripts pass `bash -n` syntax check
2. `install.sh` installs them to `/usr/local/bin/` with mode 755
3. The full smoke test lifecycle passes: create-agent → assign-reviewer →
   list-reviewers → PATH enforcement → write protection → unassign-reviewer →
   delete agent
4. Each verification step has been run and its output reported

## This machine

- OS: Arch Linux
- Primary user: nick
- Target install: `/usr/local/bin/`
- Restricted agent PATH: `/opt/agents/bin/`
