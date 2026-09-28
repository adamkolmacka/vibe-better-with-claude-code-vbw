#!/usr/bin/env bats

# dev-launch.sh must pass the repo root as --plugin-dir, including when it is
# invoked through the ~/.local/bin/claude-vbw symlink installed by dev-setup.sh.

load test_helper

setup() {
  setup_temp_dir
  mkdir -p "$TEST_TEMP_DIR/bin" "$TEST_TEMP_DIR/links"
  printf '#!/bin/bash\necho "claude $*"\n' > "$TEST_TEMP_DIR/bin/claude"
  chmod +x "$TEST_TEMP_DIR/bin/claude"
  REPO_REAL="$(cd "$PROJECT_ROOT" && pwd -P)"
}

teardown() {
  teardown_temp_dir
}

@test "dev-launch: direct invocation passes repo root as --plugin-dir" {
  run env PATH="$TEST_TEMP_DIR/bin:$PATH" bash "$SCRIPTS_DIR/dev-launch.sh" --resume
  [ "$status" -eq 0 ]
  [ "$output" = "claude --plugin-dir $REPO_REAL --resume" ]
}

@test "dev-launch: absolute symlink resolves to repo root" {
  ln -s "$REPO_REAL/scripts/dev-launch.sh" "$TEST_TEMP_DIR/links/claude-vbw"
  run env PATH="$TEST_TEMP_DIR/bin:$PATH" "$TEST_TEMP_DIR/links/claude-vbw"
  [ "$status" -eq 0 ]
  [ "$output" = "claude --plugin-dir $REPO_REAL" ]
}

@test "dev-launch: chained relative symlink resolves to repo root" {
  ln -s "$REPO_REAL/scripts/dev-launch.sh" "$TEST_TEMP_DIR/links/target"
  (cd "$TEST_TEMP_DIR/links" && ln -s target claude-vbw)
  run env PATH="$TEST_TEMP_DIR/bin:$PATH" "$TEST_TEMP_DIR/links/claude-vbw"
  [ "$status" -eq 0 ]
  [ "$output" = "claude --plugin-dir $REPO_REAL" ]
}
