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

cat > "$tmp_dir/bin/opencode" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${OPENCODE_AUTH_CONTENT:-}" != *'"opencode-go"'* ]]; then
  echo "missing opencode auth content" >&2
  exit 1
fi

model=""
for ((i = 1; i <= $#; i++)); do
  if [[ "${!i}" == "--model" ]]; then
    next=$((i + 1))
    model="${!next}"
  fi
done

if [[ "$model" != "opencode-go/glm-5.2" ]]; then
  printf 'expected opencode-go model, got: %s\n' "$model" >&2
  exit 1
fi

prompt="${!#}"
if [[ "$prompt" != *"Stub task"* ]]; then
  echo "prompt did not include loaded task" >&2
  exit 1
fi

overview="$(backlog instructions overview)"
if [[ "$overview" != "Backlog workflow instructions." ]]; then
  printf 'expected backlog shim to expose workflow instructions, got: %s\n' "$overview" >&2
  exit 1
fi
STUB
chmod +x "$tmp_dir/bin/opencode"

cat > "$tmp_dir/bin/gh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'https://github.com/example/repo/pull/1\n'
STUB
chmod +x "$tmp_dir/bin/gh"

export PATH="$tmp_dir/bin:$PATH"
cd "$tmp_dir/workspace"
git init --initial-branch=main >/dev/null
git config commit.gpgsign false
git remote add origin https://github.com/example/repo.git
printf 'initial\n' > README.md
git add README.md
git -c user.name=test -c user.email=test@example.com commit -m initial >/dev/null

export GITHUB_WORKSPACE="$tmp_dir/workspace"
export GITHUB_ACTION_PATH="$repo_root"
export GITHUB_REF_NAME="main"
export GITHUB_REPOSITORY="example/repo"
export GITHUB_OUTPUT="$tmp_dir/github-output"
export INPUT_BACKLOG_TASK_ID="task-1"
export INPUT_PROVIDER="opencode"
export INPUT_GITHUB_TOKEN="dummy-token"
export INPUT_OPENCODE_MODEL="opencode-go/glm-5.2"
export INPUT_OPENCODE_GO_SUBSCRIPTION_KEY="dummy-opencode-key"
export INPUT_DRAFT="true"
export INPUT_FAIL_ON_EMPTY_DIFF="false"

bash "$repo_root/scripts/entrypoint.sh"

if ! grep -F 'branch=backlog-to-pr/task-1-' "$GITHUB_OUTPUT" >/dev/null; then
  echo "entrypoint opencode test failed: branch output was not written" >&2
  exit 1
fi

echo "entrypoint opencode tests passed"
