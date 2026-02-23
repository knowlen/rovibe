<div align="center">

[![AUR version](https://img.shields.io/aur/version/rovibe)](https://aur.archlinux.org/packages/rovibe)
[![License: WTFPL](https://img.shields.io/badge/license-WTFPL-brightgreen)](LICENSE)

</div>

![rovibe architechture](docs/rovibe-diag.svg)

Modern LLM coding agents can trivially circumvent prompt-based restrictions and config files 
like `.claude/settings.json`. **Rovibe** provisions OS user accounts with restricted PATHs and read-only 
symlink mirrors of a project for isolated Claude Code sessions (eg; "reviewer" agents). 
Sort of like virtual environments, but for users (agents... or interns) & enforced by the kernel instead of the runtime.





## How it works
Each agent gets:
- A dedicated user account on the operating system with access only to an explicit binary allowlist (`/opt/agents/bin/`)
- A read-only mirror of the target project
- A writable scratch space for review output

Agent-to-agent message passing via prompt injection is planned.

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

Tested on Arch Linux. macOS support soon.

## License

WTFPL
