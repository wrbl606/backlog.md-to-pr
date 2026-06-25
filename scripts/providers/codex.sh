#!/usr/bin/env bash
set -euo pipefail

install_codex() {
  if [[ -n "${INPUT_CODEX_INSTALL_COMMAND:-}" ]]; then
    bash -lc "$INPUT_CODEX_INSTALL_COMMAND"
  elif ! command -v codex >/dev/null 2>&1; then
    npm install -g @openai/codex
  fi

  command -v codex >/dev/null 2>&1 || {
    echo "backlog-to-pr: Codex CLI was not found after installation" >&2
    exit 1
  }
}

run_codex() {
  args=(exec --cd "$GITHUB_WORKSPACE" --sandbox workspace-write --ask-for-approval never)

  if [[ -n "${INPUT_CODEX_MODEL:-}" ]]; then
    args+=(--model "$INPUT_CODEX_MODEL")
  fi

  if [[ -n "${INPUT_CODEX_ARGS:-}" ]]; then
    read -r -a extra_args <<< "$INPUT_CODEX_ARGS"
    args+=("${extra_args[@]}")
  fi

  codex "${args[@]}" - < "$BACKLOG_TO_PR_PROMPT"
}

case "${1:-}" in
  install)
    install_codex
    ;;
  run)
    run_codex
    ;;
  *)
    echo "usage: $0 install|run" >&2
    exit 2
    ;;
esac
