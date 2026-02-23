#!/usr/bin/env bash
set -euo pipefail

SCRIPT="install.sh"
log()  { echo "[$SCRIPT] $*"; }
err()  { echo "[$SCRIPT] ERROR: $*" >&2; exit 1; }

BIN_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib/rovibe"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HELPERS=(create-agent sync-mirror assign-reviewer unassign-reviewer launch-reviewer list-reviewers uninstall.sh)

# --- Remove old standalone scripts from /usr/local/bin ---
log "Removing old standalone scripts from $BIN_DIR..."
for script in "${HELPERS[@]}"; do
  if [[ -f "$BIN_DIR/$script" ]]; then
    rm -f "$BIN_DIR/$script"
    log "  Removed $BIN_DIR/$script"
  fi
done

# --- Install rovibe dispatcher ---
log "Installing rovibe dispatcher to $BIN_DIR..."
[[ -f "$SCRIPT_DIR/rovibe" ]] || err "Dispatcher not found: $SCRIPT_DIR/rovibe"
install -m 755 "$SCRIPT_DIR/rovibe" "$BIN_DIR/rovibe"
log "  Installed rovibe -> $BIN_DIR/rovibe"

# --- Install lib helpers ---
log "Installing helpers to $LIB_DIR..."
mkdir -p "$LIB_DIR"

for script in "${HELPERS[@]}"; do
  src="$SCRIPT_DIR/lib/$script"
  dst="$LIB_DIR/$script"
  [[ -f "$src" ]] || err "Helper not found: $src"
  install -m 755 "$src" "$dst"
  log "  Installed $script -> $dst"
done

log "Installation complete."
