#!/bin/bash
set -euo pipefail
repo="$HOME/.openclaw_temp_repo"
if [ ! -d "$repo" ]; then
  git clone https://github.com/openclaw/openclaw "$repo"
fi
cd "$repo"
git fetch origin
main_hash=$(git rev-parse origin/main)
main_tag=$(git describe --tags --abbrev=0 "origin/main" 2>/dev/null || echo "<no tag>")
state_file="$repo/.last_main_hash"
main_action="Main already at $main_tag ($main_hash)"
if [ "$(cat "$state_file" 2>/dev/null)" != "$main_hash" ]; then
  pnpm add -g "https://github.com/openclaw/openclaw#$main_hash"
  echo "$main_hash" > "$state_file"
  main_action="Updated CLI to main commit $main_tag ($main_hash)"
fi
beta_result=$(openclaw update --channel beta 2>&1)
stable_result=$(openclaw update --channel stable 2>&1)
beta_line=$(echo "$beta_result" | tail -n1)
stable_line=$(echo "$stable_result" | tail -n1)
summary="$main_action; Beta: $beta_line; Stable: $stable_line; Release notes: https://github.com/openclaw/openclaw/releases"
echo "$summary"
