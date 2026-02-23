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
  --purge   Also remove /opt/agents/bin/ and the 'agents' group

Will refuse to uninstall if any agent users still exist in the
'agents' group. Delete all agents first with `rovibe delete agent <name>`.
EOF
  exit 1
}

[[ $EUID -eq 0 ]] || err "Must be run as root"

PURGE=false
for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=true ;;
    -h|--help) usage ;;
    *) err "Unknown option: $arg" ;;
  esac
done

# Block if any agent users still exist
if getent group agents >/dev/null 2>&1; then
  MEMBERS_LINE=$(getent group agents | cut -d: -f4)
  if [[ -n "$MEMBERS_LINE" ]]; then
    err "Cannot uninstall: agents group still has members: $MEMBERS_LINE
Delete all agents first with: rovibe delete agent <name>"
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
  # Remove agents bin directory
  if [[ -d /opt/agents/bin ]]; then
    rm -rf /opt/agents/bin
    log "Removed /opt/agents/bin/"
  else
    log "/opt/agents/bin/ not found, skipping"
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
