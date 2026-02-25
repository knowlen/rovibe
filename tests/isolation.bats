#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

# Derive project dir from test file location, no hardcoded paths
PROJECT_DIR="${ROVIBE_TEST_PROJECT:-$(cd "$BATS_TEST_DIRNAME/.." && pwd)}"

setup_file() {
  # Detect AppArmor availability
  APPARMOR_ACTIVE=false
  if [[ -f /sys/module/apparmor/parameters/enabled ]] && \
     [[ "$(<  /sys/module/apparmor/parameters/enabled)" == "Y" ]] && \
     [[ -d /etc/apparmor.d/abstractions ]] && \
     command -v aa-exec >/dev/null 2>&1 && \
     command -v apparmor_parser >/dev/null 2>&1; then
    APPARMOR_ACTIVE=true
  fi
  export APPARMOR_ACTIVE

  # Create dummy binary for AppArmor denial tests
  echo '#!/bin/bash' | sudo tee /usr/local/bin/rovibe-test-dummy > /dev/null
  echo 'echo SANDBOX_ESCAPE' | sudo tee -a /usr/local/bin/rovibe-test-dummy > /dev/null
  sudo chmod +x /usr/local/bin/rovibe-test-dummy

  # Create primary test agent and assign to project
  rovibe create t.rouge
  rovibe assign t.rouge "$PROJECT_DIR" --role test
}

teardown_file() {
  # Sweep all t.* agents unconditionally, catch leaked agents from
  # failed tests. Use run so bats does not abort on nonzero exit.
  for u in t.rouge t.readonly t.isolated t.other t.profiletest t.aa-test; do
    run rovibe delete "$u"
  done
  sudo rm -f /usr/local/bin/rovibe-test-dummy
}

teardown() {
  # Per-test cleanup for resources that can leak on assertion failure
  sudo rm -f /usr/local/bin/evilcat 2>/dev/null || true
  sudo rm -f /opt/evil/evilcat 2>/dev/null || true
  sudo rmdir /opt/evil 2>/dev/null || true
  sudo rm -f /opt/rovibe/t.rouge/bin/fakefile 2>/dev/null || true
  # Ensure ps is not left in bin between tests
  sudo rm -f /opt/rovibe/t.rouge/bin/ps 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Bin directory permissions
# ---------------------------------------------------------------------------

@test "agent bin is owned by root:agents" {
  run stat -c "%U %G" /opt/rovibe/t.rouge/bin
  [ "$status" -eq 0 ]
  [ "$output" = "root agents" ]
}

@test "agent bin is mode 755" {
  run stat -c "%a" /opt/rovibe/t.rouge/bin
  [ "$status" -eq 0 ]
  [ "$output" = "755" ]
}

@test "agent cannot write to own bin" {
  run sudo -u t.rouge touch /opt/rovibe/t.rouge/bin/testfile
  [ "$status" -ne 0 ]
  [[ "$output" == *"Permission denied"* ]]
}

@test "agent cannot delete from own bin" {
  run sudo -u t.rouge rm /opt/rovibe/t.rouge/bin/bash
  [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# PATH sandbox boundary
# These tests document known limitations of the PATH-based sandbox model.
# An agent with bash in their allowlist can always invoke absolute paths
# or strip PATH restrictions via --norc. This is a known architectural
# constraint, rovibe's isolation model is identity/filesystem, not
# syscall-level. Mark with skip to document without failing CI.
# ---------------------------------------------------------------------------

@test "XFAIL: agent can bypass PATH restriction via absolute path" {
  skip "PATH bypass documented limitation; AppArmor enforcement tests cover the hard sandbox equivalent"
  run sudo -u t.rouge bash --login -c '/usr/bin/curl --version'
  [ "$status" -ne 0 ]
}

@test "XFAIL: agent can bypass PATH restriction via bash --norc" {
  skip "PATH bypass documented limitation; AppArmor enforcement tests cover the hard sandbox equivalent"
  run sudo -u t.rouge bash --login -c \
    'bash --norc -c "export PATH=/usr/bin:/usr/local/bin; which curl"'
  [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Command access through restricted PATH
# ---------------------------------------------------------------------------

@test "agent can execute allowed command through login shell" {
  run sudo -u t.rouge bash --login -c "bash -c 'echo hello'"
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]
}

@test "agent cannot run command not in bin through login shell" {
  run -127 sudo -u t.rouge bash --login -c "nc 2>&1"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]] || [[ "$output" == *"No such file"* ]]
}

@test "agent cannot run sudo through login shell" {
  run -127 sudo -u t.rouge bash --login -c "sudo echo hi 2>&1"
  [ "$status" -ne 0 ]
}

@test "agent cannot run su through login shell" {
  run -127 sudo -u t.rouge bash --login -c "su -c 'whoami' 2>&1"
  [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Profile correctness (before allow/restrict to avoid custom profile taint)
# ---------------------------------------------------------------------------

@test "default profile is standard" {
  run cat /opt/rovibe/t.rouge/.rovibe-profile
  [ "$status" -eq 0 ]
  [ "$output" = "standard" ]
}

@test "allow marks profile as custom" {
  # Use a fresh agent to avoid polluting t.rouge profile state
  rovibe create t.profiletest
  rovibe allow t.profiletest ps
  run cat /opt/rovibe/t.profiletest/.rovibe-profile
  [ "$output" = "custom" ]
  run rovibe delete t.profiletest
}

@test "read-only profile excludes curl and includes grep" {
  rovibe create t.readonly --profile read-only
  [ ! -e /opt/rovibe/t.readonly/bin/curl ]
  [ ! -e /opt/rovibe/t.readonly/bin/wget ]
  [ ! -e /opt/rovibe/t.readonly/bin/git ]
  [ -e /opt/rovibe/t.readonly/bin/grep ]
  # cleanup in teardown_file()
}

@test "network-isolated profile excludes git but includes python3" {
  rovibe create t.isolated --profile network-isolated
  [ ! -e /opt/rovibe/t.isolated/bin/curl ]
  [ ! -e /opt/rovibe/t.isolated/bin/git ]
  if command -v vim >/dev/null 2>&1; then
    [ -e /opt/rovibe/t.isolated/bin/vim ]
  fi
  [ -e /opt/rovibe/t.isolated/bin/touch ]
  [ -e /opt/rovibe/t.isolated/bin/python3 ]
  # cleanup in teardown_file()
}

@test "unknown profile is rejected" {
  run rovibe create t.badprofile --profile hacker
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown profile"* ]]
}

@test "create is idempotent" {
  # Running create twice should succeed and not corrupt state
  rovibe create t.rouge
  run cat /opt/rovibe/t.rouge/.rovibe-profile
  [ "$output" = "standard" ]
}

# ---------------------------------------------------------------------------
# allow/restrict correctness
# ---------------------------------------------------------------------------

@test "allow adds symlink pointing to approved prefix" {
  rovibe allow t.rouge ps
  run stat -c "%F" /opt/rovibe/t.rouge/bin/ps
  [ "$output" = "symbolic link" ]
  run readlink /opt/rovibe/t.rouge/bin/ps
  [[ "$output" == /usr/bin/* ]] || [[ "$output" == /bin/* ]]
}

@test "allow rejects command name containing slash" {
  run rovibe allow t.rouge ../../../usr/bin/bash
  [[ "$output" == *"must not contain '/'"* ]]
}

@test "allow rejects binary outside approved prefixes via symlink" {
  sudo mkdir -p /opt/evil
  sudo cp /usr/bin/cat /opt/evil/evilcat
  sudo ln -sf /opt/evil/evilcat /usr/local/bin/evilcat
  run rovibe allow t.rouge evilcat
  [[ "$output" == *"not in approved location"* ]]
  # cleanup happens in teardown()
}

@test "restrict removes symlink" {
  rovibe allow t.rouge ps
  rovibe restrict t.rouge ps
  [ ! -e /opt/rovibe/t.rouge/bin/ps ]
}

@test "restrict skips non-symlink files" {
  sudo touch /opt/rovibe/t.rouge/bin/fakefile
  run rovibe restrict t.rouge fakefile
  [[ "$output" == *"not a symlink"* ]]
  [ -e /opt/rovibe/t.rouge/bin/fakefile ]
  # cleanup happens in teardown()
}

@test "restrict errors on nonexistent agent" {
  skip "requires H4 fix: restrict missing agent existence check"
  run rovibe restrict nonexistent.agent bash
  [ "$status" -ne 0 ]
  [[ "$output" == *"Agent user"*"does not exist"* ]]
}

# ---------------------------------------------------------------------------
# Home directory isolation
# ---------------------------------------------------------------------------

@test "agent home is not readable by other agents" {
  rovibe create t.other
  run sudo -u t.other bash --login -c "ls /home/t.rouge 2>&1"
  [ "$status" -ne 0 ]
  # cleanup in teardown_file()
}

@test "agent cannot read root home" {
  run sudo -u t.rouge bash --login -c "ls /root 2>&1"
  [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Cross-agent scratch isolation
# C4 from code review: scratch dirs currently use agents group
# permissions. This test documents the expected behavior after the
# C4 security fix is applied (scratch dirs mode 700, agent-owned).
# ---------------------------------------------------------------------------

@test "XFAIL: agent cannot read another agent's scratch dir" {
  skip "requires C4 fix: scratch dirs currently group-writable via agents group"
  rovibe create t.other
  rovibe assign t.other "$PROJECT_DIR" --role test
  local scratch="$PROJECT_DIR/.scratch/reviews/t.other"
  sudo -u t.other bash --login -c "echo secret > '$scratch/secret.txt'" || true
  run sudo -u t.rouge bash --login -c "cat '$scratch/secret.txt' 2>&1"
  [ "$status" -ne 0 ]
  # cleanup in teardown_file()
}

# ---------------------------------------------------------------------------
# Mirror access
# ---------------------------------------------------------------------------

@test "agent can read their mirror" {
  run sudo -u t.rouge bash --login -c \
    "ls /home/t.rouge/mirrors/$(basename "$PROJECT_DIR") 2>&1"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Workflow commands
# ---------------------------------------------------------------------------

@test "unassign removes agent assignment" {
  rovibe assign t.rouge "$PROJECT_DIR" --role test
  rovibe unassign t.rouge "$PROJECT_DIR"
  # Assignment should be gone from list
  run rovibe list t.rouge
  [[ "$output" != *"$(basename "$PROJECT_DIR")"* ]] || \
    [[ "$output" == *"-"* ]]
  # Re-assign for subsequent tests
  rovibe assign t.rouge "$PROJECT_DIR" --role test
}

@test "list shows assigned agent" {
  run rovibe list t.rouge
  [ "$status" -eq 0 ]
  [[ "$output" == *"$(basename "$PROJECT_DIR")"* ]]
}

@test "list per-agent shows ALLOWED COMMANDS section" {
  skip "not yet implemented in lib/list"
  run rovibe list t.rouge
  [[ "$output" == *"ALLOWED COMMANDS"* ]]
}

@test "global list shows PROFILE column" {
  run rovibe list
  [[ "$output" == *"PROFILE"* ]]
  [[ "$output" == *"t.rouge"* ]]
}

@test "sync-mirror creates symlinks for files in project" {
  # Ensure assignment exists regardless of prior test state
  rovibe assign t.rouge "$PROJECT_DIR" --role test 2>/dev/null || true
  run sudo -u t.rouge bash --login -c \
    "stat /home/t.rouge/mirrors/$(basename "$PROJECT_DIR")/rovibe 2>&1"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# AppArmor profile lifecycle
# ---------------------------------------------------------------------------

@test "AppArmor: profile exists after create" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  [ -f /etc/apparmor.d/rovibe/rovibe-t.rouge ]
}

@test "AppArmor: profile loaded in enforce mode" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  run aa-status
  [[ "$output" == *"rovibe-t.rouge"* ]]
}

@test "AppArmor: profile updated after allow adds command" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  rovibe allow t.rouge ps
  target=$(realpath "$(command -v ps)")
  run grep "$target" /etc/apparmor.d/rovibe/rovibe-t.rouge
  [ "$status" -eq 0 ]
}

@test "AppArmor: profile updated after restrict removes command" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  rovibe allow t.rouge ps
  rovibe restrict t.rouge ps
  target=$(realpath "$(command -v ps)")
  run grep "$target" /etc/apparmor.d/rovibe/rovibe-t.rouge
  [ "$status" -ne 0 ]
}

@test "AppArmor: profile removed after delete" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  rovibe create t.aa-test
  [ -f /etc/apparmor.d/rovibe/rovibe-t.aa-test ]
  rovibe delete t.aa-test
  [ ! -f /etc/apparmor.d/rovibe/rovibe-t.aa-test ]
}

# ---------------------------------------------------------------------------
# AppArmor hard sandbox enforcement
# ---------------------------------------------------------------------------

@test "AppArmor: agent cannot execute unlisted binary via absolute path" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  run aa-exec -p rovibe-t.rouge -- sudo -u t.rouge \
    bash --login -c '/usr/local/bin/rovibe-test-dummy 2>&1'
  [ "$status" -ne 0 ]
  [[ "$output" != *"SANDBOX_ESCAPE"* ]]
}

@test "AppArmor: agent cannot bypass via bash --norc" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  run aa-exec -p rovibe-t.rouge -- sudo -u t.rouge \
    bash --login -c 'bash --norc -c "export PATH=/usr/local/bin; rovibe-test-dummy" 2>&1'
  [ "$status" -ne 0 ]
  [[ "$output" != *"SANDBOX_ESCAPE"* ]]
}

@test "AppArmor: agent cannot bypass via python3 os.system()" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  run aa-exec -p rovibe-t.rouge -- sudo -u t.rouge \
    bash --login -c 'python3 -c "import os; exit(os.system(\"/usr/local/bin/rovibe-test-dummy\"))" 2>&1'
  [ "$status" -ne 0 ]
  [[ "$output" != *"SANDBOX_ESCAPE"* ]]
}

@test "AppArmor: agent cannot bypass via python3 subprocess" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  run aa-exec -p rovibe-t.rouge -- sudo -u t.rouge \
    bash --login -c 'python3 -c "import subprocess; subprocess.run([\"/usr/local/bin/rovibe-test-dummy\"])" 2>&1'
  [ "$status" -ne 0 ]
  [[ "$output" != *"SANDBOX_ESCAPE"* ]]
}

@test "AppArmor: agent CAN execute allowed commands under confinement" {
  $APPARMOR_ACTIVE || skip "AppArmor not available"
  run sudo -u t.rouge aa-exec -p rovibe-t.rouge -- \
    bash --login -c 'echo hello 2>/dev/null'
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]
}
