#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

make_stub_bin() {
  local name="$1"
  local body="$2"

  cat > "$tmp_dir/bin/$name" <<STUB
#!/usr/bin/env bash
set -euo pipefail
$body
STUB
  chmod +x "$tmp_dir/bin/$name"
}

mkdir -p "$tmp_dir/bin" "$tmp_dir/workspace"
export PATH="$tmp_dir/bin:$PATH"
export GITHUB_WORKSPACE="$tmp_dir/workspace"
export BACKLOG_TO_PR_PROMPT="$tmp_dir/prompt.md"
export INPUT_CODEX_MODEL=""
export INPUT_CODEX_ARGS=""
export INPUT_OPENCODE_MODEL="opencode-go/glm-5.2"
export INPUT_OPENCODE_AGENT=""
export INPUT_OPENCODE_ARGS=""
export INPUT_OPENCODE_GO_SUBSCRIPTION_KEY=""

cat > "$BACKLOG_TO_PR_PROMPT" <<'PROMPT'
Follow these task instructions.

- Preserve multiline content.
- Do not treat this as a file path.
PROMPT

cat > "$tmp_dir/capture-opencode.js" <<'NODE'
const fs = require("node:fs")
const args = process.argv.slice(2)
fs.writeFileSync(process.env.OPENCODE_ARGS_FILE, JSON.stringify(args))
NODE
make_stub_bin "opencode" 'node "$OPENCODE_CAPTURE_SCRIPT" "$@"'

export OPENCODE_ARGS_FILE="$tmp_dir/opencode-args.json"
export OPENCODE_CAPTURE_SCRIPT="$tmp_dir/capture-opencode.js"
bash "$repo_root/scripts/providers/opencode.sh" run

node - "$OPENCODE_ARGS_FILE" "$BACKLOG_TO_PR_PROMPT" <<'NODE'
const fs = require("node:fs")
const [argsPath, promptPath] = process.argv.slice(2)
const args = JSON.parse(fs.readFileSync(argsPath, "utf8"))
const prompt = fs.readFileSync(promptPath, "utf8").replace(/\n+$/, "")

if (args.includes("--file")) {
  throw new Error("opencode should receive prompt content as the message, not via --file")
}
if (args.at(-1) !== prompt) {
  throw new Error(`opencode final argument should be the generated prompt content. Captured: ${JSON.stringify(args)}`)
}
if (!args.includes("run") || !args.includes("--dir") || !args.includes(process.env.GITHUB_WORKSPACE)) {
  throw new Error("opencode run arguments are missing expected workspace options")
}
const modelIndex = args.indexOf("--model")
if (modelIndex === -1 || args[modelIndex + 1] !== "opencode-go/glm-5.2") {
  throw new Error(`opencode-go model should be preserved. Captured: ${JSON.stringify(args)}`)
}
NODE

make_stub_bin "codex" 'printf "%s\n" "$@" > "$CODEX_ARGS_FILE"
cat > "$CODEX_STDIN_FILE"'

export CODEX_ARGS_FILE="$tmp_dir/codex-args.txt"
export CODEX_STDIN_FILE="$tmp_dir/codex-stdin.txt"
bash "$repo_root/scripts/providers/codex.sh" run

if ! grep -Fx -- "-" "$CODEX_ARGS_FILE" >/dev/null; then
  echo "provider test failed: codex should read prompt content from stdin with '-' argument" >&2
  exit 1
fi
if grep -Fx -- "--ask-for-approval" "$CODEX_ARGS_FILE" >/dev/null; then
  echo "provider test failed: codex should not receive removed --ask-for-approval flag" >&2
  exit 1
fi
if ! grep -Fx -- "--sandbox" "$CODEX_ARGS_FILE" >/dev/null || ! grep -Fx -- "workspace-write" "$CODEX_ARGS_FILE" >/dev/null; then
  echo "provider test failed: codex should run with workspace-write sandbox" >&2
  exit 1
fi
if ! grep -Fx -- "--config" "$CODEX_ARGS_FILE" >/dev/null || ! grep -Fx -- 'approval_policy="never"' "$CODEX_ARGS_FILE" >/dev/null; then
  echo "provider test failed: codex should disable approval prompts with approval_policy config" >&2
  exit 1
fi
if ! cmp -s "$BACKLOG_TO_PR_PROMPT" "$CODEX_STDIN_FILE"; then
  diff -u "$BACKLOG_TO_PR_PROMPT" "$CODEX_STDIN_FILE"
  echo "provider test failed: codex stdin should match generated prompt bytes" >&2
  exit 1
fi

echo "provider tests passed"
