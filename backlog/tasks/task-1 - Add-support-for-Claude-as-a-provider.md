---
id: TASK-1
title: Add support for Claude as a provider
status: In Progress
assignee:
  - '@codex'
created_date: '2026-06-25 11:07'
updated_date: '2026-06-25 12:25'
labels: []
dependencies: []
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add Claude Code CLI as a supported provider for the backlog-to-pr GitHub Action so users can solve Backlog.md tasks with Claude in the same provider-adapter flow as Codex and OpenCode.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The action accepts provider: claude and exposes Claude-specific inputs for install command, model, and extra CLI args.
- [ ] #2 A scripts/providers/claude.sh adapter implements install and run using the generated BACKLOG_TO_PR_PROMPT in the checked out workspace.
- [ ] #3 README usage, inputs, and provider adapter docs include Claude.
- [ ] #4 The repository workflow allows selecting claude as a provider and passes the expected Claude authentication secret/environment.
- [ ] #5 Shell/YAML validation covers the new adapter and action metadata.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Fixed the self workflow token path so backlog-to-pr uses BACKLOG_TO_PR_GITHUB_TOKEN when present, falling back to github.token. This lets generated branches that touch .github/workflows push with a PAT or GitHub App token that has workflow-file write permission.

Validation passed for workflow-token fix: npm test; Ruby YAML parse for .github/workflows/backlog-to-pr.yml and action.yml.
<!-- SECTION:NOTES:END -->
