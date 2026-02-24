#!/usr/bin/env bash
set -euo pipefail

SCRIPT="uninstall"
log()  { echo "[$SCRIPT] $*"; }
err()  { echo "[$SCRIPT] ERROR: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: rovibe uninstall [--purge]

Removes rovibe from the system.

Options:
  --purge   Auto-delete all agents, remove /opt/rovibe/, and the 'agents' group

Without --purge, will refuse to uninstall if any agent users still exist
in the 'agents' group. Delete them first or use --purge to auto-delete.
EOF
  exit 1
}

if [[ $EUID -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

PURGE=false
for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=true ;;
    -h|--help) usage ;;
    *) err "Unknown option: $arg" ;;
  esac
done

# Handle existing agent users
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if getent group agents >/dev/null 2>&1; then
  MEMBERS_LINE=$(getent group agents | cut -d: -f4)
  if [[ -n "$MEMBERS_LINE" ]]; then
    if $PURGE; then
      log "Auto-deleting agent users: $MEMBERS_LINE"
      for user in $(echo "$MEMBERS_LINE" | tr ',' ' '); do
        "$SCRIPT_DIR/create-agent" "$user" --delete
      done
    else
      err "Cannot uninstall: agents group still has members: $MEMBERS_LINE
Delete all agents first with: rovibe delete <name>
Or use --purge to auto-delete all agents."
    fi
  fi
fi

# Remove dispatcher
if [[ -f /usr/local/bin/rovibe ]]; then
  rm -f /usr/local/bin/rovibe
  log "Removed /usr/local/bin/rovibe"
else
  log "/usr/local/bin/rovibe not found, skipping"
fi

# Remove lib directory
if [[ -d /usr/local/lib/rovibe ]]; then
  rm -rf /usr/local/lib/rovibe
  log "Removed /usr/local/lib/rovibe/"
else
  log "/usr/local/lib/rovibe/ not found, skipping"
fi

if $PURGE; then
  # Remove per-agent bin directories
  if [[ -d /opt/rovibe ]]; then
    rm -rf /opt/rovibe
    log "Removed /opt/rovibe/"
  else
    log "/opt/rovibe/ not found, skipping"
  fi

  # Remove legacy /opt/agents if it exists
  if [[ -d /opt/agents ]]; then
    rm -rf /opt/agents
    log "Removed legacy /opt/agents/"
  fi

  # Remove agents group
  if getent group agents >/dev/null 2>&1; then
    groupdel agents
    log "Removed 'agents' group"
  else
    log "'agents' group not found, skipping"
  fi
fi

log "Uninstall complete."
