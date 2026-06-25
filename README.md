# backlog-to-pr

`backlog-to-pr` is a GitHub Action that loads a Backlog.md task from the checked out repository, gives the task context to a coding CLI, commits the resulting repository changes, and opens a pull request.

Supported providers:

- Codex CLI (`provider: codex`)
- OpenCode CLI (`provider: opencode`)

## Usage

```yaml
name: Backlog task to PR

on:
  workflow_dispatch:
    inputs:
      backlog_task_id:
        description: Backlog.md task ID, for example task-7
        required: true

permissions:
  contents: write
  pull-requests: write

jobs:
  solve:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.BACKLOG_TO_PR_GITHUB_TOKEN || github.token }}

      - uses: your-org/backlog-to-pr@v1
        with:
          backlog-task-id: ${{ inputs.backlog_task_id }}
          github-token: ${{ secrets.BACKLOG_TO_PR_GITHUB_TOKEN || github.token }}
```

The default `github.token` can push normal code changes and open pull requests with the permissions above. If a generated branch may create or update files under `.github/workflows`, set `BACKLOG_TO_PR_GITHUB_TOKEN` to a fine-grained PAT or GitHub App token that has repository contents and workflow-file write permission; otherwise GitHub rejects the push.

For Codex, provide the authentication expected by Codex CLI in the runner environment, for example `OPENAI_API_KEY`.

For OpenCode, provide the provider credentials expected by OpenCode. OpenCode supports environment-backed provider keys and its own auth configuration.

For OpenCode Go, set the repository secret `OPENCODE_GO_SUBSCRIPTION_KEY` and pass it with `opencode-go-subscription-key`. The action exposes it to OpenCode through `OPENCODE_AUTH_CONTENT`.

## OpenCode

```yaml
- uses: your-org/backlog-to-pr@v1
  with:
    backlog-task-id: ${{ inputs.backlog_task_id }}
    provider: opencode
    opencode-model: opencode-go/glm-5.2
    opencode-go-subscription-key: ${{ secrets.OPENCODE_GO_SUBSCRIPTION_KEY }}
```

OpenCode Go subscription keys are configured for the `opencode-go/...` provider id, for example `opencode-go/glm-5.2`. If `opencode-go-subscription-key` is set and `opencode-model` uses `opencode/...`, the action rewrites it to `opencode-go/...` before invoking OpenCode.

The default OpenCode install command is:

```bash
npm install -g opencode-ai
```

Override it with `opencode-install-command` if your runner uses another installation method.

## Repository Config

By default the action reads configuration from `./backlog-to-pr` in the checked out repository. Override this with `config-dir`.

Supported files:

- `initial-prompt.md`: base instructions prepended to the loaded Backlog.md task context.
- `setup.sh`: optional setup hook, run before file editing.
- `file-edit.sh`: optional file editing hook. The default calls the configured provider adapter.
- `verify.sh`: optional verification hook, run after file editing and before commit.

The hook scripts receive these environment variables:

- `BACKLOG_TO_PR_TICKET_ID`
- `BACKLOG_TO_PR_TICKET_MARKDOWN`
- `BACKLOG_TO_PR_WORKFLOW_MARKDOWN`
- `BACKLOG_TO_PR_PROMPT`
- `BACKLOG_TO_PR_PROVIDER`
- `BACKLOG_TO_PR_ACTION_PATH`

`BACKLOG_TO_PR_TICKET_MARKDOWN` contains the output of `backlog task <id> --plain`. `BACKLOG_TO_PR_WORKFLOW_MARKDOWN` contains `backlog instructions overview` when available.

Runtime files are written under `RUNNER_TEMP` by default so generated prompt and task context files are not included in the repository diff.

Before running hooks or a provider, the action adds a runtime `backlog` shim to `PATH`. This lets provider subprocesses follow Backlog.md workflow instructions with commands like `backlog instructions overview` even when Backlog.md is only available through `npx --no-install backlog`.

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `backlog-task-id` | required | Backlog.md task ID, for example `7`, `task-7`, or `BACK-7`. |
| `github-token` | `${{ github.token }}` | Token for branch push and PR creation. Use a token with workflow-file write permission when commits can touch `.github/workflows`. |
| `config-dir` | `./backlog-to-pr` | Repo-local config directory. |
| `provider` | `codex` | Provider adapter name. Supported values are `codex` and `opencode`. |
| `base-branch` | checked out branch | PR base branch. |
| `branch-prefix` | `backlog-to-pr` | Generated branch prefix. |
| `commit-message` | `Solve {ticket}` | Commit message template. |
| `pr-title` | `{ticket}: {summary}` | PR title template. |
| `pr-body` | generated | Optional PR body template. |
| `pr-labels` | | Comma-separated PR labels. |
| `draft` | `false` | Create a draft PR. |
| `backlog-install-command` | `npm install -g backlog.md` | Backlog.md install command, used only when `npx --no-install backlog` and `backlog` are unavailable. |
| `codex-install-command` | `npm install -g @openai/codex` | Codex install command. |
| `codex-model` | | Optional Codex model. |
| `codex-args` | | Extra arguments for `codex exec`. |
| `opencode-install-command` | `npm install -g opencode-ai` | OpenCode install command. |
| `opencode-model` | | Optional OpenCode model in `provider/model` form. |
| `opencode-agent` | | Optional OpenCode agent name. |
| `opencode-go-subscription-key` | | Optional OpenCode Go subscription API key. |
| `opencode-args` | | Extra arguments for `opencode run`. |
| `fail-on-empty-diff` | `true` | Fail if no changes are produced. |

## Provider Adapters

Adapters live in `scripts/providers`. Each adapter supports:

```bash
adapter.sh install
adapter.sh run
```

`run` reads `BACKLOG_TO_PR_PROMPT` and is responsible for invoking the coding CLI in the checked out repository.
