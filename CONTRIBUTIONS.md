# Contributing to backlog-to-pr

Thanks for your interest in contributing to `backlog-to-pr`! This document
explains how to set up a development environment, the contribution workflow, and
the standards every change is expected to meet.

## Development Environment

`backlog-to-pr` is a GitHub Action implemented as shell scripts plus a small
JavaScript dev dependency for the Backlog.md CLI. The only runtime requirement
is Node.js.

1. **Install Node.js 24** (the version pinned in `.mise.toml`). If you use
   [mise](https://mise.jdx.dev/), run `mise install` in the repository root.
2. **Install dependencies**:

   ```bash
   npm install
   ```

   This installs the Backlog.md CLI used by the test suite.
3. **Fork and clone** the repository, then create a feature branch for your
   work (see [Pull Request Workflow](#pull-request-workflow) below).
4. **Verify your setup** by running the test suite:

   ```bash
   npm test
   ```

   `npm test` runs the scripts under `scripts/test-*.sh`, which exercise
   backlog loading, provider adapters, and the OpenCode entrypoint path in an
   isolated temporary workspace.

## Project Layout

- `scripts/` — entrypoint and helper scripts for the GitHub Action.
- `scripts/providers/` — provider adapters (`codex.sh`, `opencode.sh`).
- `backlog-to-pr/` — repo-local config directory consumed by the action
  (`initial-prompt.md`, `setup.sh`, `file-edit.sh`, `verify.sh`).
- `backlog/` — Backlog.md project data (tasks, config). Do not edit these
  files directly; use the `backlog` CLI.
- `.github/workflows/` — CI workflows.
- `action.yml` — Action input/output declaration.
- `README.md` — user-facing documentation.

## Contribution Workflow

This project uses Backlog.md to track work. Prefer creating or updating a
Backlog.md task for anything beyond a trivial, mechanical change.

### Pull Request Workflow

1. **Open or pick a task.** Search existing tasks first:

   ```bash
   backlog search "your topic" --plain
   backlog task list --status "To Do" --plain
   ```

   If no task fits, create one (`backlog instructions task-creation` guides
   scoping). For a one-line typo fix, skip the task and edit directly.
2. **Create a feature branch** from the default branch:

   ```bash
   git switch -c feature/short-description
   ```

   `backlog-to-pr` itself generates branches prefixed with `backlog-to-pr/`;
   avoid that prefix for manual work so automation branches stay distinct.
3. **Make the smallest coherent change.** Keep commits focused; one logical
   change per branch is ideal. Preserve unrelated user changes and existing
   conventions.
4. **Update or add tests** when the change warrants it (see
   [Testing](#testing)).
5. **Verify locally** before pushing:

   ```bash
   npm test
   ```

   Optionally run hooks you change through
   `backlog-to-pr/{setup,file-edit,verify}.sh` in a throwaway workspace.
6. **Open a pull request** against the default branch. Reference the Backlog.md
   task ID in the PR description (for example `Solves Backlog.md task TASK-6`)
   so the task, PR, and review stay linked.
7. **Respond to review.** Address feedback with new commits (avoid
   force-pushing during review unless asked). Once approved, a maintainer
   merges.

### Backlog.md Tasks

When working on a tracked task, follow the Backlog.md workflow:

- `backlog instructions overview` — start every request here.
- `backlog instructions task-execution` — planning and progress updates.
- `backlog instructions task-finalization` — verification and completion.
- Use `backlog task edit TASK-123 ...` to record plans, notes, checked
  acceptance criteria, and final summaries. Never edit Backlog.md markdown
  files directly; the CLI keeps metadata consistent.

## Coding Standards

### Shell Scripts

Most of the codebase is Bash. Follow the conventions already in use:

- Start every script with:

  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  ```

- Exit on errors (`-e`), treat unset variables as errors (`-u`), and fail on
  pipe failures (`-o pipefail`).
- Use `die()` helpers for actionable error messages, mirroring
  `scripts/entrypoint.sh`.
- Quote variable expansions and prefer `printf` over `echo` for literal output.
- Keep scripts portable for the `ubuntu-latest` runner environment.

### Action and Provider Adapters

- Provider adapters live in `scripts/providers/` and must support
  `adapter.sh install` and `adapter.sh run`, where `run` reads
  `BACKLOG_TO_PR_PROMPT` and invokes the coding CLI in the checked out
  repository. Match the structure of `codex.sh` and `opencode.sh` when adding
  adapters.
- Add or extend inputs in `action.yml` and document them in `README.md` in the
  same change.
- Keep runtime files (prompts, task context) under `RUNNER_TEMP` so they do
  not leak into the repository diff.

### Documentation

- Update `README.md` when inputs, defaults, or behavior change.
- Keep `AGENTS.md` and Backlog.md guidance untouched unless explicitly reworking
  the workflow itself.

## Testing

Run the full suite locally before pushing:

```bash
npm test
```

`npm test` executes, in order:

1. `scripts/test-providers.sh` — provider adapter install/run behavior with
   stubbed binaries.
2. `scripts/test-load-backlog.sh` — the Backlog.md loader using an `npx` stub.
3. `scripts/test-entrypoint-opencode.sh` — the OpenCode entrypoint path end to
   end.

When adding or changing script behavior:

- Add or extend a focused test under `scripts/test-*.sh` and wire it into the
  `npm test` runner in `package.json`.
- Tests create an isolated temp workspace and stub external binaries (`npx`,
  `codex`, `opencode`, `gh`); never depend on real network or credentials.
- Keep tests hermetic and fast.

## Commit Conventions

This repository uses [Conventional Commits](https://www.conventionalcommits.org/).
Recent history uses prefixes such as:

- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation only
- `chore:` — tooling, maintenance, config
- `refactor:` — behavior-preserving refactor
- `test:` — tests only
- `task:` — Backlog.md task tracking metadata

Write commits in the imperative mood (`fix: codex orchestration`, not `fixed`).
Keep the summary line short; put detail in the body when needed.

Reference a Backlog.md task ID in the commit body when a commit closes or
relates to tracked work, for example:

```
fix: provider shim resolution

Relates to TASK-7.
```

## Pull Request Expectations

- One logical change per PR, described in terms a reviewer can follow without
  reading every diff line.
- Title and body follow the conventions above; the PR description references
  the related Backlog.md task when one exists.
- All acceptance criteria for a related task are checked via `backlog task edit`
  before requesting review, and the task carries a final summary.
- `npm test` passes locally on the latest default branch plus your changes.
- New or changed behavior is documented in `README.md` (and `action.yml` for
  inputs) as part of the same PR.
- No secrets, tokens, or runtime-generated files are committed.

We look forward to your contribution!