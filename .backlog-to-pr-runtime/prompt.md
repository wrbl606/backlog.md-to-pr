You are running in a GitHub Actions workspace to solve the Backlog.md task below.

Make the smallest coherent repository change that addresses the task. Read the project before editing. Preserve unrelated user changes. Add or update tests when the change warrants it. Run focused verification before finishing.

Use the included Backlog.md workflow instructions for task execution and finalization. Prefer `backlog task edit` commands over manual edits when updating task notes, acceptance criteria, or final summaries.


---

File: /Users/marcinwroblewski/Documents/Projects/backlog-to-pr/backlog/tasks/task-1 - Add-support-for-Claude-as-a-provider.md

Task TASK-1 - Add support for Claude as a provider
==================================================

Status: ○ To Do
Ordinal: 1000
Created: 2026-06-25 11:07

Description:
--------------------------------------------------
Add Claude Code CLI as a supported provider for the backlog-to-pr GitHub Action so users can solve Backlog.md tasks with Claude in the same provider-adapter flow as Codex and OpenCode.

Acceptance Criteria:
--------------------------------------------------
- [ ] #1 The action accepts provider: claude and exposes Claude-specific inputs for install command, model, and extra CLI args.
- [ ] #2 A scripts/providers/claude.sh adapter implements install and run using the generated BACKLOG_TO_PR_PROMPT in the checked out workspace.
- [ ] #3 README usage, inputs, and provider adapter docs include Claude.
- [ ] #4 The repository workflow allows selecting claude as a provider and passes the expected Claude authentication secret/environment.
- [ ] #5 Shell/YAML validation covers the new adapter and action metadata.

Definition of Done:
--------------------------------------------------
No Definition of Done items defined



---

# Backlog.md Workflow Instructions

## Backlog.md Overview (CLI)

This project uses Backlog.md to track features, bugs, and structured work as tasks.

### When to Use Backlog

Create a task when the work requires planning, decisions, or handoff notes.

Ask: "Do I need to think about HOW to do this?"

- Yes: search for an existing task first, then create one if needed.
- No: do the small mechanical change directly.

Create tasks for work like bug fixes that need investigation, feature work, API changes, refactors, or anything that should be reviewed as a commitment. Skip task creation for questions, explanations, quick lookups, and obvious mechanical edits.

### Start Every Request Here

Use this overview to decide what to read or run next. The detailed guides contain the procedure for creating, executing, and finalizing tasks.

Search and read before changing anything:

- `backlog search "query" --plain`
- `backlog task list --status "<todo status>" --plain`
- `backlog task list --status "<active status>" --plain`
- `backlog task list --search "login" --labels frontend,bug --limit 20 --plain`
- `backlog task view TASK-123 --plain`

### Detailed Guides

Always read the relevant guide before that part of the workflow. Do not rely on this overview alone for these actions:

- `backlog instructions task-creation`
  -> Read before creating tasks: how to search, scope, and create tasks
- `backlog instructions task-execution`
  -> Read before planning or updating task work: how to plan, update, and work through tasks
- `backlog instructions task-finalization`
  -> Read before finishing tasks: how to verify, summarize, and finish tasks

Use `backlog <command> --help` before unfamiliar operations. Command help includes input fields, read/write behavior, output shape, and examples.

### Core Principle

Backlog tracks committed work: what will be built, fixed, or changed. Use the CLI for Backlog changes so metadata, file names, relationships, and history stay consistent.

Important: Do not edit Backlog task, draft, document, decision, or milestone markdown files directly. Use Backlog commands so automatic metadata stays complete.


---

Runtime paths:
- Backlog task Markdown: /Users/marcinwroblewski/Documents/Projects/backlog-to-pr/.backlog-to-pr-runtime/task.md
- Backlog workflow instructions: /Users/marcinwroblewski/Documents/Projects/backlog-to-pr/.backlog-to-pr-runtime/workflow.md
