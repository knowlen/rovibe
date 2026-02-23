#!/usr/bin/env bash
set -euo pipefail

SCRIPT="install.sh"
log()  { echo "[$SCRIPT] $*"; }
err()  { echo "[$SCRIPT] ERROR: $*" >&2; exit 1; }

INSTALL_DIR="/usr/local/bin"
SCRIPTS=(create-agent sync-mirror assign-reviewer unassign-reviewer launch-reviewer list-reviewers)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Installing rovibe scripts to $INSTALL_DIR..."

for script in "${SCRIPTS[@]}"; do
  src="$SCRIPT_DIR/$script"
  dst="$INSTALL_DIR/$script"

  [[ -f "$src" ]] || err "Script not found: $src"

  install -m 755 "$src" "$dst"
  log "  Installed $script -> $dst"
done

log "Installation complete. All scripts installed to $INSTALL_DIR."
