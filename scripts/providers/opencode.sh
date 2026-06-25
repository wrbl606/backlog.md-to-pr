#!/usr/bin/env bash
set -euo pipefail

install_opencode() {
  if [[ -n "${INPUT_OPENCODE_INSTALL_COMMAND:-}" ]]; then
    bash -lc "$INPUT_OPENCODE_INSTALL_COMMAND"
  elif ! command -v opencode >/dev/null 2>&1; then
    npm install -g opencode-ai
  fi

  command -v opencode >/dev/null 2>&1 || {
    echo "backlog-to-pr: OpenCode CLI was not found after installation" >&2
    exit 1
  }
}

run_opencode() {
  args=(run --dir "$GITHUB_WORKSPACE" --dangerously-skip-permissions)

  if [[ -n "${INPUT_OPENCODE_MODEL:-}" ]]; then
    args+=(--model "$INPUT_OPENCODE_MODEL")
  fi

  if [[ -n "${INPUT_OPENCODE_AGENT:-}" ]]; then
    args+=(--agent "$INPUT_OPENCODE_AGENT")
  fi

  if [[ -n "${INPUT_OPENCODE_ARGS:-}" ]]; then
    read -r -a extra_args <<< "$INPUT_OPENCODE_ARGS"
    args+=("${extra_args[@]}")
  fi

  args+=(--file "$BACKLOG_TO_PR_PROMPT")

  opencode "${args[@]}" "Follow the instructions in the attached backlog-to-pr prompt."
}

case "${1:-}" in
  install)
    install_opencode
    ;;
  run)
    run_opencode
    ;;
  *)
    echo "usage: $0 install|run" >&2
    exit 2
    ;;
esac
