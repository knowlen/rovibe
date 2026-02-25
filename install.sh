#!/usr/bin/env bash
set -euo pipefail

SCRIPT="install.sh"
log()  { echo "[$SCRIPT] $*"; }
err()  { echo "[$SCRIPT] ERROR: $*" >&2; exit 1; }

ensure_claude_traversable() {
  local claude_bin="$1"
  local sudo_user="$2"
  local target_dir
  target_dir=$(dirname "$claude_bin")

  # Build list of directory components to check
  local path=""
  local components=()
  IFS='/' read -ra parts <<< "$target_dir"
  for part in "${parts[@]}"; do
    [[ -z "$part" ]] && continue
    path="$path/$part"
    components+=("$path")
  done

  for dir in "${components[@]}"; do
    # Safety: never touch /root or anything under it
    if [[ "$dir" == "/root" || "$dir" == /root/* ]]; then
      log "SKIP chmod: '$dir' is under /root, manual intervention required"
      return 1
    fi

    # Must be a directory
    if [[ ! -d "$dir" ]]; then
      log "SKIP chmod: '$dir' is not a directory"
      continue
    fi

    # Must be owned by root or the invoking user
    local owner
    owner=$(stat -c "%U" "$dir")
    if [[ "$owner" != "root" && "$owner" != "$sudo_user" ]]; then
      log "SKIP chmod: '$dir' owned by '$owner' (not root or $sudo_user)"
      return 1
    fi

    # Check if already traversable by others
    local perms
    perms=$(stat -c "%a" "$dir")
    if (( 8#$perms % 2 == 1 )); then
      continue
    fi

    # Safe to chmod, only add execute for others
    chmod o+x "$dir"
    log "  chmod o+x $dir"
  done
}

BIN_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib/rovibe"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HELPERS=(create-agent sync-mirror assign unassign launch list allow restrict uninstall.sh apparmor)

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

# Provision system resources
groupadd -f agents
# Per-agent bins live under /opt/rovibe/<agent>/bin/, created by create-agent.
# Legacy /opt/agents/bin/ is not removed, left for manual cleanup.
mkdir -p /opt/rovibe
log "Provisioned agents group and /opt/rovibe"

# --- Ensure agents can execute claude ---
log "Detecting claude installation..."
CLAUDE_BIN=""
if [[ -n "${SUDO_USER:-}" ]]; then
  CLAUDE_BIN=$(sudo -u "$SUDO_USER" bash -c 'command -v claude' 2>/dev/null || true)
fi
if [[ -z "$CLAUDE_BIN" && -n "${SUDO_USER:-}" && -x "/home/$SUDO_USER/.claude/local/claude" ]]; then
  CLAUDE_BIN="/home/$SUDO_USER/.claude/local/claude"
fi

if [[ -z "$CLAUDE_BIN" ]]; then
  log "WARN: claude not found, skipping traversal fix. Install Claude Code before using rovibe launch."
elif [[ "$CLAUDE_BIN" == /root/* ]]; then
  log "WARN: claude is under /root, cannot grant agent access safely. Move claude to a non-root location."
else
  CLAUDE_BIN=$(realpath "$CLAUDE_BIN")
  log "  Found claude at: $CLAUDE_BIN"

  # Safety: refuse if binary is world-writable
  bin_perms=$(stat -c "%a" "$CLAUDE_BIN")
  if (( 8#$bin_perms & 0002 )); then
    log "WARN: '$CLAUDE_BIN' is world-writable, refusing to grant access. Fix permissions first."
  else
    ensure_claude_traversable "$CLAUDE_BIN" "${SUDO_USER:-$USER}"
  fi
fi

# --- Generate AppArmor profiles for existing agents ---
source "$LIB_DIR/apparmor"
if apparmor_available; then
  log "AppArmor detected, generating profiles for existing agents..."
  for agent_dir in /opt/rovibe/*/; do
    [[ -d "$agent_dir/bin" ]] || continue
    agent=$(basename "$agent_dir")
    apparmor_generate_profile "$agent"
    log "  Generated profile: rovibe-$agent"
  done
else
  log "AppArmor not available, execution sandboxing disabled"
fi

log "Installation complete."
