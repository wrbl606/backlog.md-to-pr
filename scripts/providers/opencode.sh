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

configure_opencode_go_auth() {
  if [[ -z "${INPUT_OPENCODE_GO_SUBSCRIPTION_KEY:-}" ]]; then
    return
  fi

  OPENCODE_AUTH_CONTENT="$(node <<'NODE'
const fs = require("node:fs")
const os = require("node:os")
const path = require("node:path")

const authPath = path.join(os.homedir(), ".local", "share", "opencode", "auth.json")
let auth = {}

if (process.env.OPENCODE_AUTH_CONTENT) {
  try {
    auth = JSON.parse(process.env.OPENCODE_AUTH_CONTENT)
  } catch {}
} else {
  try {
    auth = JSON.parse(fs.readFileSync(authPath, "utf8"))
  } catch {}
}

auth.opencode = {
  type: "api",
  key: process.env.INPUT_OPENCODE_GO_SUBSCRIPTION_KEY,
}

process.stdout.write(JSON.stringify(auth))
NODE
)"
  export OPENCODE_AUTH_CONTENT
}

run_opencode() {
  configure_opencode_go_auth

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

  local prompt
  prompt="$(cat "$BACKLOG_TO_PR_PROMPT")"
  opencode "${args[@]}" "$prompt"
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
