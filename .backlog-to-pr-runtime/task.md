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

