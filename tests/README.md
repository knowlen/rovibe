# rovibe integration tests

## Requirements
- bats-core: yay -S bats
- rovibe installed: sudo bash install.sh
- Must be run with sudo or as a user with passwordless sudo

## Usage
  cd tests && sudo bats isolation.bats

## Environment variables
  ROVIBE_TEST_PROJECT  Path to rovibe repo (default: parent of tests/)

## Warning
Tests create and delete real Linux system users (t.rouge, t.readonly,
t.isolated, t.other, t.profiletest). Do not run on production systems.
All t.* users are cleaned up in teardown_file() even if tests fail.

## Known limitations
Two tests are marked skip (XFAIL) documenting that PATH-based restriction
is not a hard security boundary. These are intentional, rovibe's isolation
model is OS identity and filesystem, not syscall-level sandboxing.
