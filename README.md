![rovibe architechture](docs/rovibe-diag.svg)

This tool provisions isolated OS users for Claude Code sessions. Like virtual environments, 
but enforced by the kernel instead of the runtime.

Modern LLM coding agents can trivially circumvent prompt-based restrictions and config files 
like `.claude/settings.json`. rovibe provisions real OS users with restricted PATHs and read-only 
symlink mirrors of a project, letting the kernel enforce (hard) isolation.

Each agent gets:
- A dedicated user account with access only to an explicit binary allowlist (`/opt/agents/bin/`)
- A read-only mirror of the target project
- A writable scratch space for review output

Agent-to-agent message passing via prompt injection is planned.

## How it works

Each agent is a real OS user in the `agents` group, locked to `PATH=/opt/agents/bin` (readonly in `.bashrc`), and given a symlink mirror of your project where every file points back to the source. Files are readable via group permissions but not writable. The only writable space is `.scratch/`. Hard resource limits apply on Linux (`nproc=256`, `nofile=4096`).

**TL;DR:** Unix users, groups, and file permissions. No containers or VMs. 

## Installation

### Arch Linux
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
```bash
# Create an agent
sudo rovibe create agent <username> <role>

# Assign as reviewer
sudo rovibe assign reviewer <agent> <project-dir> [--claude-md <path>]

# List reviewers
rovibe list reviewers <project-dir>

# Launch a review session
sudo rovibe launch reviewer <agent> <project-dir> [--prompt-file <path>]

# Sync mirrors after new files are added
sudo rovibe sync <project-dir>

# Unassign
sudo rovibe unassign reviewer <agent> <project-dir> [--purge-scratch]

# Delete an agent
sudo rovibe delete agent <username>

# Uninstall
sudo rovibe uninstall [--purge]
```

`--purge-scratch` removes the agent's scratch workspace. `--purge` on uninstall also removes `/opt/agents/bin/` and the `agents` group.

## Filesystem layout
```
/usr/local/bin/rovibe                    # dispatcher
/usr/local/lib/rovibe/                   # internal scripts
/opt/agents/bin/                         # restricted PATH

/home/<agent>/mirrors/<project>/         # read-only symlink mirror
    .scratch -> <project>/.scratch
    .claude/settings.local.json
    src/file.py -> /path/to/project/src/file.py

<project>/.scratch/reviews/<agent>/      # writable scratch space
```

## Requirements

- Bash, Git, standard Unix tools (`useradd`, `groupadd`, `find`, etc.)
- `fswatch` optional — enables live mirror sync during sessions

Tested on Arch Linux. macOS supported.

## License

WTFPL
