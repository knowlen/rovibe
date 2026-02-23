# rovibe

OS-level isolated identities for AI coding agents.

rovibe provisions real OS users with restricted PATHs and read-only symlink
mirrors of your project. The kernel enforces the isolation — not prompts, not
tool settings. Agents can read your code but cannot modify it, cannot access
tools outside an explicit allowlist, and cannot escape their sandbox.

## How it works

Each agent is:

- A real OS user in the `agents` group
- Locked to `PATH=/opt/agents/bin` (readonly, set in `.bashrc`)
- Given a **symlink mirror** of your project where every file links back to the
  source — readable via group permissions, but not writable
- Provided a `.scratch/` directory as their only writable workspace
- Subject to hard resource limits (`nproc=256`, `nofile=4096` on Linux)

No containers. No VMs. Just Unix users, groups, and file permissions.

## Installation

### Arch Linux (PKGBUILD)

```bash
makepkg -si
```

### Manual

```bash
sudo ./install.sh
sudo mkdir -p /opt/agents/bin
sudo groupadd -f agents
```

## Usage

All commands go through the `rovibe` dispatcher. Most require root.

### Create an agent

```bash
sudo rovibe create agent <username> <role>
```

Creates an OS user with a restricted PATH and populates `/opt/agents/bin/` with
symlinks to allowlisted binaries (coreutils, git, python3, claude, curl, jq, etc.).

### Delete an agent

```bash
sudo rovibe delete agent <username>
```

Kills the agent's processes, removes the user and home directory.

### Assign a reviewer

```bash
sudo rovibe assign reviewer <agent> <project-dir> [--claude-md <path>]
```

Sets up the full review environment:

1. Grants read-only group access on the project
2. Creates a symlink mirror at `/home/<agent>/mirrors/<project>/`
3. Creates a writable `.scratch/` workspace in the project
4. Writes Claude Code permissions restricting destructive git operations
5. Optionally copies a custom `CLAUDE.md` into the mirror

### Launch a review session

```bash
sudo rovibe launch reviewer <agent> <project-dir> [--prompt-file <path>]
```

Syncs the mirror, optionally starts a filesystem watcher, and launches Claude
Code as the agent user inside the mirror. Pass `--prompt-file` for non-interactive
mode.

### List assigned reviewers

```bash
rovibe list reviewers <project-dir>
```

Shows which agents are assigned to a project, their status, and mirror paths.

### Unassign a reviewer

```bash
sudo rovibe unassign reviewer <agent> <project-dir> [--purge-scratch]
```

Tears down the mirror. Pass `--purge-scratch` to also delete the agent's scratch
workspace.

### Sync mirrors

```bash
sudo rovibe sync <project-dir>
```

Re-syncs all assigned agents' mirrors for a project. Picks up new files added
since assignment.

### Uninstall

```bash
sudo rovibe uninstall [--purge]
```

Removes rovibe. All agents must be deleted first. Pass `--purge` to also remove
`/opt/agents/bin/` and the `agents` group.

## Filesystem layout

```
/usr/local/bin/rovibe                    # dispatcher
/usr/local/lib/rovibe/                   # lib scripts
/opt/agents/bin/                         # restricted PATH (symlinks)

/home/<agent>/
    mirrors/<project>/                   # read-only symlink mirror
        .scratch -> <project>/.scratch   # writable workspace
        .claude/settings.local.json      # tool permissions
        src/... -> /path/to/project/src  # symlinks to source

<project>/.scratch/reviews/<agent>/      # agent's scratch space
```

## Requirements

- Bash
- Git
- Standard Unix tools (`useradd`, `groupadd`, `install`, `find`, etc.)
- Optional: `fswatch` for live mirror sync during review sessions

Works on Linux (Arch) and macOS.

## License

MIT
