#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/workspace"

cat > "$tmp_dir/bin/npx" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

case "$*" in
  "--no-install backlog --version")
    printf '1.47.1\n'
    ;;
  "--no-install backlog task task-1 --plain")
    printf '# Stub task\n\nImplement the requested change.\n'
    ;;
  "--no-install backlog instructions overview")
    printf 'Backlog workflow instructions.\n'
    ;;
  *)
    printf 'unexpected npx invocation: %s\n' "$*" >&2
    exit 1
    ;;
esac
STUB
chmod +x "$tmp_dir/bin/npx"

cat > "$tmp_dir/bin/gh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$GH_ARGS_FILE"
printf 'https://github.com/example/repo/pull/1\n'
STUB
chmod +x "$tmp_dir/bin/gh"

export PATH="$tmp_dir/bin:$PATH"
export GH_ARGS_FILE="$tmp_dir/gh-args.txt"

setup_repo() {
  rm -rf "$tmp_dir/workspace" "$tmp_dir/origin.git"
  mkdir -p "$tmp_dir/workspace"
  git init --bare "$tmp_dir/origin.git" >/dev/null
  cd "$tmp_dir/workspace"
  git init --initial-branch=main >/dev/null
  git config commit.gpgsign false
  git remote add origin "$tmp_dir/origin.git"
  printf 'initial\n' > README.md
  git add README.md
  git -c user.name=test -c user.email=test@example.com commit -m initial >/dev/null
  git push -q origin main >/dev/null
}

run_entrypoint() {
  : > "$GH_ARGS_FILE"
  export GITHUB_WORKSPACE="$tmp_dir/workspace"
  export GITHUB_ACTION_PATH="$repo_root"
  export GITHUB_REF_NAME="main"
  export GITHUB_REPOSITORY=""
  export GITHUB_OUTPUT="$tmp_dir/github-output"
  export GH_TOKEN="dummy-token"
  export INPUT_BACKLOG_TASK_ID="task-1"
  export INPUT_PROVIDER="opencode"
  export INPUT_GITHUB_TOKEN="dummy-token"
  export INPUT_DRAFT="true"
  export INPUT_FAIL_ON_EMPTY_DIFF="true"
  bash "$repo_root/scripts/entrypoint.sh"
}

# Scenario 1: provider switches to a feature branch and commits there
# (reproduces the reported failure).
cat > "$tmp_dir/bin/opencode" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
git checkout -b feature/provider-work main
printf 'provider change\n' >> README.md
git add README.md
git -c user.name=provider -c user.email=provider@example.com commit -m "feat: provider work" >/dev/null
STUB
chmod +x "$tmp_dir/bin/opencode"

setup_repo
run_entrypoint

action_branch="$(git branch --show-current)"
if [[ "$action_branch" != backlog-to-pr/task-1-* ]]; then
  echo "provider-commit test failed: expected to be on backlog-to-pr branch, got '$action_branch'" >&2
  exit 1
fi

if ! git log --oneline | grep -F 'feat: provider work' >/dev/null; then
  echo "provider-commit test failed: provider commit was not brought onto the action branch" >&2
  exit 1
fi

if ! grep -F 'https://github.com/example/repo/pull/1' "$GITHUB_OUTPUT" >/dev/null; then
  echo "provider-commit test failed: pull-request-url not written to output" >&2
  exit 1
fi

if ! grep -F -- '--head backlog-to-pr/task-1-' "$GH_ARGS_FILE" >/dev/null; then
  echo "provider-commit test failed: pr create was not called with the action branch as head" >&2
  exit 1
fi

# Scenario 2: provider commits directly on the action's branch without switching.
cat > "$tmp_dir/bin/opencode" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'direct commit change\n' >> README.md
git add README.md
git -c user.name=provider -c user.email=provider@example.com commit -m "feat: direct provider work" >/dev/null
STUB
chmod +x "$tmp_dir/bin/opencode"

setup_repo
run_entrypoint

action_branch="$(git branch --show-current)"
if [[ "$action_branch" != backlog-to-pr/task-1-* ]]; then
  echo "direct-commit test failed: expected to stay on backlog-to-pr branch, got '$action_branch'" >&2
  exit 1
fi

if ! git log --oneline | grep -F 'feat: direct provider work' >/dev/null; then
  echo "direct-commit test failed: provider commit was not preserved on the action branch" >&2
  exit 1
fi

if ! grep -F 'https://github.com/example/repo/pull/1' "$GITHUB_OUTPUT" >/dev/null; then
  echo "direct-commit test failed: pull-request-url not written to output" >&2
  exit 1
fi

# Scenario 3: provider leaves uncommitted changes on the action's branch
# (the original happy path must still produce a commit with the configured message).
cat > "$tmp_dir/bin/opencode" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'uncommitted change\n' >> README.md
STUB
chmod +x "$tmp_dir/bin/opencode"

setup_repo
run_entrypoint

if ! git log --oneline | grep -F 'Solve task-1' >/dev/null; then
  echo "uncommitted test failed: expected a commit with the configured commit message" >&2
  exit 1
fi

if ! grep -F 'https://github.com/example/repo/pull/1' "$GITHUB_OUTPUT" >/dev/null; then
  echo "uncommitted test failed: pull-request-url not written to output" >&2
  exit 1
fi

echo "entrypoint provider-commit tests passed"
