#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SSH="$SCRIPT_DIR/tmux-ssh"
TEST_CONFIG="$SCRIPT_DIR/.test-tmux-ssh.conf"
TESTS_PASSED=0
TESTS_FAILED=0

# Create test config file
setup() {
  cat > "$TEST_CONFIG" << 'EOF'
[test-group-1]
host1.example.com
host2.example.com

[test-group-2]
server-a
server-b
server-c

# Comment line should be ignored
[empty-group]
EOF

  # Kill any existing test tmux sessions
  tmux kill-session -t tmux-ssh 2>/dev/null || true
  tmux kill-session -t tmux-ssh-1 2>/dev/null || true
  tmux kill-session -t custom-name 2>/dev/null || true
  tmux kill-session -t custom-name-1 2>/dev/null || true
}

teardown() {
  rm -f "$TEST_CONFIG"
  tmux kill-session -t tmux-ssh 2>/dev/null || true
  tmux kill-session -t tmux-ssh-1 2>/dev/null || true
  tmux kill-session -t custom-name 2>/dev/null || true
  tmux kill-session -t custom-name-1 2>/dev/null || true
}

pass() {
  echo -e "${GREEN}✓ $1${NC}"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
  echo -e "${RED}✗ $1${NC}"
  echo "  $2"
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Test: Help flag shows usage
test_help_flag() {
  local output
  output=$("$TMUX_SSH" -h 2>&1) || true
  if echo "$output" | grep -q "Usage:"; then
    pass "Help flag shows usage"
  else
    fail "Help flag shows usage" "Expected 'Usage:' in output"
  fi
}

# Test: Help shows -l option
test_help_shows_list_option() {
  local output
  output=$("$TMUX_SSH" -h 2>&1) || true
  if echo "$output" | grep -q "\-l"; then
    pass "Help shows -l option"
  else
    fail "Help shows -l option" "Expected '-l' in help output"
  fi
}

# Test: No arguments shows usage and exits with error
test_no_args_error() {
  local exit_code=0
  "$TMUX_SSH" 2>/dev/null || exit_code=$?
  if [[ $exit_code -eq 2 ]]; then
    pass "No arguments exits with code 2"
  else
    fail "No arguments exits with code 2" "Got exit code $exit_code"
  fi
}

# Test: List groups with no config file
test_list_no_config() {
  local exit_code=0
  local output
  # Temporarily override HOME to avoid finding real config
  output=$(HOME=/nonexistent "$TMUX_SSH" -l 2>&1) || exit_code=$?
  if [[ $exit_code -eq 1 ]] && echo "$output" | grep -q "No config file found"; then
    pass "List with no config shows error"
  else
    fail "List with no config shows error" "Expected error message, got: $output"
  fi
}

# Test: List groups from config file
test_list_groups() {
  local output
  output=$(HOME="$SCRIPT_DIR" "$TMUX_SSH" -l 2>&1)
  if echo "$output" | grep -q "test-group-1" && echo "$output" | grep -q "test-group-2"; then
    pass "List groups shows configured groups"
  else
    fail "List groups shows configured groups" "Expected groups in output: $output"
  fi
}

# Test: Group expansion returns hosts
test_group_expansion() {
  # Test config parsing using awk (portable across GNU/BSD)
  local hosts
  hosts=$(awk -v group="test-group-1" '
    /^\[.*\]$/ { in_group = ($0 == "[" group "]") }
    in_group && !/^\[/ && !/^$/ && !/^#/ { print }
  ' "$TEST_CONFIG")

  if echo "$hosts" | grep -q "host1.example.com" && echo "$hosts" | grep -q "host2.example.com"; then
    pass "Group expansion returns correct hosts"
  else
    fail "Group expansion returns correct hosts" "Got: $hosts"
  fi
}

# Test: Unknown group returns empty
test_unknown_group() {
  # Test config parsing using awk (portable across GNU/BSD)
  local hosts
  hosts=$(awk -v group="nonexistent-group" '
    /^\[.*\]$/ { in_group = ($0 == "[" group "]") }
    in_group && !/^\[/ && !/^$/ && !/^#/ { print }
  ' "$TEST_CONFIG")

  if [[ -z "$hosts" ]]; then
    pass "Unknown group returns empty"
  else
    fail "Unknown group returns empty" "Expected empty, got: $hosts"
  fi
}

# Test: Create tmux session with single host
test_create_session_single_host() {
  # Use 'echo' instead of ssh to avoid actual connections, -d to not attach
  "$TMUX_SSH" -d -p "sleep 1 && echo" testhost

  if tmux has-session -t tmux-ssh 2>/dev/null; then
    pass "Creates tmux session with default name"
    tmux kill-session -t tmux-ssh 2>/dev/null || true
  else
    fail "Creates tmux session with default name" "Session 'tmux-ssh' not found"
  fi
}

# Test: Create tmux session with custom name
test_create_session_custom_name() {
  "$TMUX_SSH" -d -p "sleep 1 && echo" -n custom-name testhost

  if tmux has-session -t custom-name 2>/dev/null; then
    pass "Creates tmux session with custom name"
    tmux kill-session -t custom-name 2>/dev/null || true
  else
    fail "Creates tmux session with custom name" "Session 'custom-name' not found"
  fi
}

# Test: Session name collision adds suffix
test_session_name_collision() {
  # Create first session
  "$TMUX_SSH" -d -p "sleep 2 && echo" -n custom-name host1

  # Create second session with same name
  "$TMUX_SSH" -d -p "sleep 2 && echo" -n custom-name host2

  if tmux has-session -t custom-name 2>/dev/null && tmux has-session -t custom-name-1 2>/dev/null; then
    pass "Session name collision adds numeric suffix"
  else
    fail "Session name collision adds numeric suffix" "Expected both 'custom-name' and 'custom-name-1'"
  fi

  tmux kill-session -t custom-name 2>/dev/null || true
  tmux kill-session -t custom-name-1 2>/dev/null || true
}

# Test: Multiple hosts create multiple panes
test_multiple_hosts_multiple_panes() {
  "$TMUX_SSH" -d -p "sleep 1 && echo" host1 host2 host3

  local pane_count
  pane_count=$(tmux list-panes -t tmux-ssh 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$pane_count" -eq 3 ]]; then
    pass "Multiple hosts create multiple panes"
  else
    fail "Multiple hosts create multiple panes" "Expected 3 panes, got $pane_count"
  fi

  tmux kill-session -t tmux-ssh 2>/dev/null || true
}

# Test: Group name expands to multiple hosts
test_group_creates_multiple_panes() {
  HOME="$SCRIPT_DIR" "$TMUX_SSH" -d -p "sleep 1 && echo" test-group-2

  local pane_count
  pane_count=$(tmux list-panes -t tmux-ssh 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$pane_count" -eq 3 ]]; then
    pass "Group expands to multiple panes"
  else
    fail "Group expands to multiple panes" "Expected 3 panes for test-group-2, got $pane_count"
  fi

  tmux kill-session -t tmux-ssh 2>/dev/null || true
}

# Test: Synchronize panes is enabled
test_synchronize_panes_enabled() {
  "$TMUX_SSH" -d -p "sleep 1 && echo" host1 host2

  local sync_status
  sync_status=$(tmux show-window-options -t tmux-ssh -v synchronize-panes 2>/dev/null)

  if [[ "$sync_status" == "on" ]]; then
    pass "Synchronize panes is enabled"
  else
    fail "Synchronize panes is enabled" "Expected 'on', got '$sync_status'"
  fi

  tmux kill-session -t tmux-ssh 2>/dev/null || true
}

# Main
main() {
  echo "Setting up tests..."
  setup

  # Rename test config to match expected location
  mv "$TEST_CONFIG" "$SCRIPT_DIR/.tmux-ssh.conf"
  TEST_CONFIG="$SCRIPT_DIR/.tmux-ssh.conf"

  echo ""
  echo "Running tests..."
  echo ""

  # Argument and help tests
  test_help_flag
  test_help_shows_list_option
  test_no_args_error

  # Config file tests
  test_list_no_config
  test_list_groups
  test_group_expansion
  test_unknown_group

  # Tmux integration tests
  test_create_session_single_host
  test_create_session_custom_name
  test_session_name_collision
  test_multiple_hosts_multiple_panes
  test_group_creates_multiple_panes
  test_synchronize_panes_enabled

  echo ""
  echo "Cleaning up..."
  teardown

  echo ""
  echo "================================"
  echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
  echo "================================"

  if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
