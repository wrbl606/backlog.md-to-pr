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

      - uses: your-org/backlog-to-pr@v1
        with:
          backlog-task-id: ${{ inputs.backlog_task_id }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

For Codex, provide the authentication expected by Codex CLI in the runner environment, for example `OPENAI_API_KEY`.

For OpenCode, provide the provider credentials expected by OpenCode. OpenCode supports environment-backed provider keys and its own auth configuration.

## OpenCode

```yaml
- uses: your-org/backlog-to-pr@v1
  with:
    backlog-task-id: ${{ inputs.backlog_task_id }}
    provider: opencode
    opencode-model: anthropic/claude-sonnet-4-5
```

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

## Inputs

| Input | Default | Description |
| --- | --- | --- |
| `backlog-task-id` | required | Backlog.md task ID, for example `7`, `task-7`, or `BACK-7`. |
| `github-token` | `${{ github.token }}` | Token for branch push and PR creation. |
| `config-dir` | `./backlog-to-pr` | Repo-local config directory. |
| `provider` | `codex` | Provider adapter name. Supported values are `codex` and `opencode`. |
| `base-branch` | checked out branch | PR base branch. |
| `branch-prefix` | `backlog-to-pr` | Generated branch prefix. |
| `commit-message` | `Solve {ticket}` | Commit message template. |
| `pr-title` | `{ticket}: {summary}` | PR title template. |
| `pr-body` | generated | Optional PR body template. |
| `pr-labels` | | Comma-separated PR labels. |
| `draft` | `false` | Create a draft PR. |
| `backlog-install-command` | `npm install -g backlog.md` | Backlog.md install command. |
| `codex-install-command` | `npm install -g @openai/codex` | Codex install command. |
| `codex-model` | | Optional Codex model. |
| `codex-args` | | Extra arguments for `codex exec`. |
| `opencode-install-command` | `npm install -g opencode-ai` | OpenCode install command. |
| `opencode-model` | | Optional OpenCode model in `provider/model` form. |
| `opencode-agent` | | Optional OpenCode agent name. |
| `opencode-args` | | Extra arguments for `opencode run`. |
| `fail-on-empty-diff` | `true` | Fail if no changes are produced. |

## Provider Adapters

Adapters live in `scripts/providers`. Each adapter supports:

```bash
adapter.sh install
adapter.sh run
```

`run` reads `BACKLOG_TO_PR_PROMPT` and is responsible for invoking the coding CLI in the checked out repository.
