# Contributing to backlog-to-pr

Thanks for your interest in contributing to `backlog-to-pr`! This document explains how to set up a development environment, the contribution workflow, and the standards we expect changes to meet.

`backlog-to-pr` is a composite GitHub Action that loads a [Backlog.md](https://backlog.md) task from the checked out repository, hands the task context to a coding CLI (Codex CLI or OpenCode CLI), commits the resulting repository changes, and opens a pull request. The action itself is implemented with Bash scripts, and project work is tracked with Backlog.md.

## Development Environment Setup

You need a Git checkout, Node.js, and the GitHub CLI.

1. **Clone the repository**

   ```bash
   git clone https://github.com/<your-fork>/backlog-to-pr.git
   cd backlog-to-pr
   ```

2. **Install Node.js 24**

   The project pins Node 24 in `.mise.toml`. If you use [mise](https://mise.jdx.dev/):

   ```bash
   mise install
   ```

   Otherwise install Node 24 through your preferred version manager (`nvm`, `fnm`, `volta`, etc.).

3. **Install dependencies**

   ```bash
   npm install
   ```

   This installs the local dev dependencies, including `backlog.md`, which is used by the test suite and by the Backlog.md workflow.

4. **GitHub CLI**

   The action shells out to `gh` to create pull requests. Install the [GitHub CLI](https://cli.github.com/) and authenticate with `gh auth login` if you plan to run the action end to end.

5. **Provider credentials (optional)**

   End to end runs require provider credentials. For Codex, provide `OPENAI_API_KEY`. For OpenCode, provide the credentials expected by your OpenCode provider; for OpenCode Go, set `OPENCODE_GO_SUBSCRIPTION_KEY`. Local script and test development does not require these.

## Running Tests

Tests are Bash scripts that exercise the loader, provider adapters, and entrypoint using stubbed binaries. Run the full suite with:

```bash
npm test
```

This runs:

- `scripts/test-providers.sh` — verifies the Codex and OpenCode adapters invoke their CLIs with the expected arguments and prompt content.
- `scripts/test-load-backlog.sh` — verifies the Backlog.md task and workflow instructions are loaded through `npx --no-install backlog`.
- `scripts/test-entrypoint-opencode.sh` — verifies the full entrypoint flow for the OpenCode provider, including branch creation and output writing.

Run a single script directly while iterating, for example:

```bash
bash scripts/test-providers.sh
```

All scripts use `set -euo pipefail` and exit non zero on failure.

## Project Layout

- `action.yml` — composite action definition and inputs.
- `scripts/entrypoint.sh` — main entrypoint: loads the task, builds the prompt, runs hooks and the provider, commits, and opens the PR.
- `scripts/load-backlog.sh` — loads the Backlog.md task and workflow instructions.
- `scripts/run-provider.sh` — dispatches to a provider adapter.
- `scripts/providers/` — provider adapters (`codex.sh`, `opencode.sh`), each supporting `install` and `run` subcommands.
- `scripts/test-*.sh` — test scripts orchestrated by `npm test`.
- `backlog-to-pr/` — default repository-local configuration consumed by the action (`initial-prompt.md`, `setup.sh`, `file-edit.sh`, `verify.sh`).
- `backlog/` — Backlog.md tasks, drafts, documents, decisions, and milestones. Manage these with the `backlog` CLI; do not edit them by hand.
- `.github/workflows/backlog-to-pr.yml` — workflow that runs the action on dispatch.

## Coding Standards

- **Shell scripts.** New and modified scripts under `scripts/` and `backlog-to-pr/` should start with `#!/usr/bin/env bash` and `set -euo pipefail`. Quote variables, prefer local variables in functions, and avoid `cd` chains where possible.
- **No direct edits to Backlog.md files.** Use the `backlog` CLI (`backlog task`, `backlog doc`, etc.) so metadata, IDs, filenames, relationships, and history stay consistent. See `AGENTS.md` for the project's Backlog.md workflow.
- **Configuration hooks.** When changing the default hook scripts in `backlog-to-pr/`, keep them small and focused; they are meant to be overridden by repository-local config.
- **Documentation.** Keep `README.md`, `action.yml` input descriptions, and this file in sync when inputs, hooks, or provider behavior change.

## Testing Requirements

- Add or update tests in `scripts/test-*.sh` (or a new `test-*.sh` script wired into `npm test`) for any change to loading, provider adapters, or the entrypoint.
- Every test script must exit non zero on failure and print a clear failure message to stderr.
- Run `npm test` before requesting review. The full suite should pass on a clean checkout.
- For documentation only changes, running the test suite is still encouraged to catch accidental script edits.

## Commit Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/) style messages, lowercase and scoped where helpful. Recent history uses these prefixes:

- `feat:` — a new feature or capability (for example, `feat: add opencode provider`).
- `fix:` — a bug fix (for example, `fix: codex orchestration`).
- `docs:` — documentation changes.
- `chore:` — maintenance, cleanup, or tooling changes.
- `task:` — Backlog.md task tracking changes.

Keep the summary line short (about 72 characters) and use the body for context when the change is non obvious.

## Contribution Workflow

We use feature branches and pull requests. Backlog.md tasks track committed work.

1. **Find or create a task.** Search first with `backlog search "<query>" --plain` and `backlog task list --plain`. Create a task with `backlog task create` for work that needs planning, decisions, or handoff notes. Skip task creation for trivial, mechanical edits.
2. **Create a feature branch.** Use a descriptive name, for example `feat/opencode-args` or `fix/codex-sandbox`. Branches generated by `backlog-to-pr` itself use the `backlog-to-pr/` prefix; avoid that prefix for human authored branches.
3. **Make your changes.** Keep changes small and focused. Follow the coding standards above and update or add tests as described in [Testing Requirements](#testing-requirements).
4. **Run verification locally.**

   ```bash
   npm test
   ```

5. **Commit.** Write a Conventional Commits style message as described above.
6. **Open a pull request.** Push your branch and open a PR against the default branch. Reference the Backlog.md task ID in the PR description when one exists, for example `Solves TASK-6`.
7. **Respond to review.** Address review comments with new commits (avoid force pushing once review has started unless requested). Update the Backlog.md task notes with `backlog task edit <id> --append-notes "..."` to record decisions and progress.
8. **Finalize.** Once the PR is merged, update the Backlog.md task status with `backlog task edit <id> -s "Done"` and, if applicable, record a final summary with `--final-summary`.

## Reporting Issues and Proposing Features

Open a GitHub issue describing the problem or proposal. For work that warrants tracking, a maintainer will create a Backlog.md task and link it to the issue. For small fixes, you are welcome to open a PR directly with a clear description of the change.

## Questions

If anything in this document is unclear or inaccurate, open an issue or a PR improving it. Contributions to this file are welcome and follow the same workflow described above.
