#!/usr/bin/env bash
set -euo pipefail

die() {
  echo "backlog-to-pr: $*" >&2
  exit 1
}

BACKLOG_CMD=()

resolve_backlog_cmd() {
  if command -v npx >/dev/null 2>&1 && npx --no-install backlog --version >/dev/null 2>&1; then
    BACKLOG_CMD=(npx --no-install backlog)
    return 0
  fi

  if command -v backlog >/dev/null 2>&1; then
    BACKLOG_CMD=(backlog)
    return 0
  fi

  return 1
}

install_backlog() {
  if resolve_backlog_cmd; then
    return
  fi

  if [[ -n "${INPUT_BACKLOG_INSTALL_COMMAND:-}" ]]; then
    bash -lc "$INPUT_BACKLOG_INSTALL_COMMAND"
  fi

  resolve_backlog_cmd || die "Backlog.md CLI was not found after installation"
}

install_backlog

"${BACKLOG_CMD[@]}" task "$INPUT_BACKLOG_TASK_ID" --plain > "$BACKLOG_TO_PR_TICKET_MARKDOWN"
[[ -s "$BACKLOG_TO_PR_TICKET_MARKDOWN" ]] || die "Backlog.md returned an empty task for $INPUT_BACKLOG_TASK_ID"

if "${BACKLOG_CMD[@]}" instructions overview > "$BACKLOG_TO_PR_WORKFLOW_MARKDOWN" 2>/dev/null; then
  :
else
  printf 'Backlog.md workflow instructions were unavailable from `backlog instructions overview`.\n' > "$BACKLOG_TO_PR_WORKFLOW_MARKDOWN"
fi
