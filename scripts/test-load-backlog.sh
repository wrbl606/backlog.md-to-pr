#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
export PATH="$tmp_dir/bin:$PATH"
export INPUT_BACKLOG_TASK_ID="task-123"
export INPUT_BACKLOG_INSTALL_COMMAND=""
export BACKLOG_TO_PR_TICKET_MARKDOWN="$tmp_dir/task.md"
export BACKLOG_TO_PR_WORKFLOW_MARKDOWN="$tmp_dir/workflow.md"
export BACKLOG_CALLS_FILE="$tmp_dir/backlog-calls.txt"

cat > "$tmp_dir/bin/npx" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >> "$BACKLOG_CALLS_FILE"

case "$*" in
  "--no-install backlog --version")
    printf '1.7.1\n'
    ;;
  "--no-install backlog task task-123 --plain")
    printf '# Loaded task\n\nTask body.\n'
    ;;
  "--no-install backlog instructions overview")
    printf 'Workflow instructions.\n'
    ;;
  *)
    printf 'unexpected npx invocation: %s\n' "$*" >&2
    exit 1
    ;;
esac
STUB
chmod +x "$tmp_dir/bin/npx"

bash "$repo_root/scripts/load-backlog.sh"

if ! grep -F '# Loaded task' "$BACKLOG_TO_PR_TICKET_MARKDOWN" >/dev/null; then
  echo "load-backlog test failed: task output was not written" >&2
  exit 1
fi

if ! grep -F 'Workflow instructions.' "$BACKLOG_TO_PR_WORKFLOW_MARKDOWN" >/dev/null; then
  echo "load-backlog test failed: workflow instructions were not written" >&2
  exit 1
fi

if grep -F 'backlog ' "$BACKLOG_CALLS_FILE" | grep -vF -- '--no-install backlog' >/dev/null; then
  echo "load-backlog test failed: expected backlog invocations to go through npx --no-install" >&2
  exit 1
fi

echo "load-backlog tests passed"
