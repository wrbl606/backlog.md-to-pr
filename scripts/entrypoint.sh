#!/usr/bin/env bash
set -euo pipefail

die() {
  echo "backlog-to-pr: $*" >&2
  exit 1
}

replace_token() {
  local value="$1"
  local ticket="$2"
  local summary="$3"
  value="${value//\{ticket\}/$ticket}"
  value="${value//\{summary\}/$summary}"
  printf '%s' "$value"
}

require_input() {
  local name="$1"
  local value="$2"
  [[ -n "$value" ]] || die "missing required input: $name"
}

configure_backlog_path() {
  local shim_dir="$BACKLOG_TO_PR_RUNTIME_DIR/bin"
  local fallback_backlog="${BACKLOG_TO_PR_ORIGINAL_BACKLOG:-}"

  mkdir -p "$shim_dir"
  cat > "$shim_dir/backlog" <<'SHIM'
#!/usr/bin/env bash
set -euo pipefail

cd "$GITHUB_WORKSPACE"

if command -v npx >/dev/null 2>&1 && npx --no-install backlog --version >/dev/null 2>&1; then
  exec npx --no-install backlog "$@"
fi

if [[ -n "${BACKLOG_TO_PR_ORIGINAL_BACKLOG:-}" && -x "$BACKLOG_TO_PR_ORIGINAL_BACKLOG" ]]; then
  exec "$BACKLOG_TO_PR_ORIGINAL_BACKLOG" "$@"
fi

echo "backlog-to-pr: Backlog.md CLI was not found" >&2
exit 127
SHIM
  chmod +x "$shim_dir/backlog"
  export PATH="$shim_dir:$PATH"
  export BACKLOG_TO_PR_ORIGINAL_BACKLOG="$fallback_backlog"
}

require_input "backlog-task-id" "${INPUT_BACKLOG_TASK_ID:-}"
require_input "github-token" "${INPUT_GITHUB_TOKEN:-}"

[[ -n "${GITHUB_WORKSPACE:-}" ]] || die "GITHUB_WORKSPACE is not set"
[[ -n "${GITHUB_ACTION_PATH:-}" ]] || die "GITHUB_ACTION_PATH is not set"

cd "$GITHUB_WORKSPACE"
git rev-parse --show-toplevel >/dev/null 2>&1 || die "the workspace must be a Git repository; run actions/checkout before backlog-to-pr"
command -v gh >/dev/null 2>&1 || die "GitHub CLI (gh) is required on the runner"
if command -v backlog >/dev/null 2>&1; then
  export BACKLOG_TO_PR_ORIGINAL_BACKLOG="$(command -v backlog)"
fi

export BACKLOG_TO_PR_ACTION_PATH="$GITHUB_ACTION_PATH"
export BACKLOG_TO_PR_TICKET_ID="$INPUT_BACKLOG_TASK_ID"
export BACKLOG_TO_PR_PROVIDER="${INPUT_PROVIDER:-codex}"

runtime_parent="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
runtime_parent="${runtime_parent%/}"
runtime_id="${GITHUB_RUN_ID:-$$}"
export BACKLOG_TO_PR_RUNTIME_DIR="${BACKLOG_TO_PR_RUNTIME_DIR:-$runtime_parent/backlog-to-pr-runtime-$runtime_id}"
export BACKLOG_TO_PR_TICKET_MARKDOWN="$BACKLOG_TO_PR_RUNTIME_DIR/task.md"
export BACKLOG_TO_PR_WORKFLOW_MARKDOWN="$BACKLOG_TO_PR_RUNTIME_DIR/workflow.md"
export BACKLOG_TO_PR_PROMPT="$BACKLOG_TO_PR_RUNTIME_DIR/prompt.md"

config_dir="${INPUT_CONFIG_DIR:-./backlog-to-pr}"
if [[ "$config_dir" != /* ]]; then
  config_dir="$GITHUB_WORKSPACE/${config_dir#./}"
fi
fallback_config="$GITHUB_ACTION_PATH/backlog-to-pr"

mkdir -p "$BACKLOG_TO_PR_RUNTIME_DIR"

"$GITHUB_ACTION_PATH/scripts/load-backlog.sh"

if command -v backlog >/dev/null 2>&1; then
  export BACKLOG_TO_PR_ORIGINAL_BACKLOG="$(command -v backlog)"
fi
configure_backlog_path

summary="$(sed -n 's/^# *//p' "$BACKLOG_TO_PR_TICKET_MARKDOWN" | head -n 1)"
if [[ -z "$summary" ]]; then
  summary="$(sed -n '1p' "$BACKLOG_TO_PR_TICKET_MARKDOWN")"
fi
summary="${summary:-Backlog.md task $INPUT_BACKLOG_TASK_ID}"

safe_ticket="$(printf '%s' "$INPUT_BACKLOG_TASK_ID" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9._-' '-')"
branch="${INPUT_BRANCH_PREFIX:-backlog-to-pr}/$safe_ticket-$(date +%Y%m%d%H%M%S)"
base_branch="${INPUT_BASE_BRANCH:-}"

if [[ -z "$base_branch" ]]; then
  base_branch="$(git branch --show-current)"
fi
if [[ -z "$base_branch" && -n "${GITHUB_REF_NAME:-}" ]]; then
  base_branch="$GITHUB_REF_NAME"
fi
[[ -n "$base_branch" ]] || die "could not determine base branch; set base-branch"

git config user.name "${GIT_AUTHOR_NAME:-backlog-to-pr[bot]}"
git config user.email "${GIT_AUTHOR_EMAIL:-backlog-to-pr[bot]@users.noreply.github.com}"
git checkout -B "$branch"

initial_prompt="$fallback_config/initial-prompt.md"
if [[ -f "$config_dir/initial-prompt.md" ]]; then
  initial_prompt="$config_dir/initial-prompt.md"
fi

{
  cat "$initial_prompt"
  printf '\n\n---\n\n'
  cat "$BACKLOG_TO_PR_TICKET_MARKDOWN"
  printf '\n\n---\n\n'
  printf '# Backlog.md Workflow Instructions\n\n'
  cat "$BACKLOG_TO_PR_WORKFLOW_MARKDOWN"
  printf '\n\n---\n\n'
  printf 'Runtime paths:\n'
  printf -- '- Backlog task Markdown: %s\n' "$BACKLOG_TO_PR_TICKET_MARKDOWN"
  printf -- '- Backlog workflow instructions: %s\n' "$BACKLOG_TO_PR_WORKFLOW_MARKDOWN"
} > "$BACKLOG_TO_PR_PROMPT"

setup_script=""
if [[ -f "$config_dir/setup.sh" ]]; then
  setup_script="$config_dir/setup.sh"
elif [[ -f "$fallback_config/setup.sh" ]]; then
  setup_script="$fallback_config/setup.sh"
fi
if [[ -n "$setup_script" ]]; then
  bash "$setup_script"
fi

file_edit_script="$fallback_config/file-edit.sh"
if [[ -f "$config_dir/file-edit.sh" ]]; then
  file_edit_script="$config_dir/file-edit.sh"
fi
bash "$file_edit_script"

verify_script=""
if [[ -f "$config_dir/verify.sh" ]]; then
  verify_script="$config_dir/verify.sh"
elif [[ -f "$fallback_config/verify.sh" ]]; then
  verify_script="$fallback_config/verify.sh"
fi
if [[ -n "$verify_script" ]]; then
  bash "$verify_script"
fi

git add -A

if git diff --cached --quiet; then
  if [[ "${INPUT_FAIL_ON_EMPTY_DIFF:-true}" == "true" ]]; then
    die "provider completed without producing repository changes"
  fi
  echo "backlog-to-pr: no repository changes to commit"
  {
    echo "pull-request-url="
    echo "branch=$branch"
  } >> "$GITHUB_OUTPUT"
  exit 0
fi

commit_message="$(replace_token "${INPUT_COMMIT_MESSAGE:-Solve {ticket}}" "$INPUT_BACKLOG_TASK_ID" "$summary")"
git commit -m "$commit_message"

if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
  git remote set-url origin "https://x-access-token:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
fi
git push --set-upstream origin "$branch"

title="$(replace_token "${INPUT_PR_TITLE:-{ticket}: {summary}}" "$INPUT_BACKLOG_TASK_ID" "$summary")"
if [[ -n "${INPUT_PR_BODY:-}" ]]; then
  body="$(replace_token "$INPUT_PR_BODY" "$INPUT_BACKLOG_TASK_ID" "$summary")"
else
  body="$(cat <<BODY
Solves Backlog.md task $INPUT_BACKLOG_TASK_ID.

Task summary: $summary

Generated by backlog-to-pr using provider: $BACKLOG_TO_PR_PROVIDER.
BODY
)"
fi

gh_args=(pr create --base "$base_branch" --head "$branch" --title "$title" --body "$body")
if [[ "${INPUT_DRAFT:-false}" == "true" ]]; then
  gh_args+=(--draft)
fi
if [[ -n "${INPUT_PR_LABELS:-}" ]]; then
  gh_args+=(--label "$INPUT_PR_LABELS")
fi

export GH_TOKEN="$INPUT_GITHUB_TOKEN"
pr_url="$(gh "${gh_args[@]}")"

{
  echo "pull-request-url=$pr_url"
  echo "branch=$branch"
} >> "$GITHUB_OUTPUT"

echo "backlog-to-pr: created $pr_url"
