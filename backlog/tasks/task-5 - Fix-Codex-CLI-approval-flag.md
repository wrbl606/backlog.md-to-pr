---
id: TASK-5
title: Fix Codex CLI approval flag
status: Done
assignee:
  - '@codex'
created_date: '2026-06-25 12:11'
updated_date: '2026-06-25 12:13'
labels: []
dependencies: []
priority: high
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The GitHub Action fails with newer Codex CLI versions because the codex provider passes the removed --ask-for-approval flag. Update the provider command and related coverage/docs so workflow_dispatch with provider=codex runs successfully.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Codex provider no longer passes unsupported --ask-for-approval to codex exec
- [x] #2 Codex provider still disables interactive approval prompts in CI using the supported Codex CLI option
- [x] #3 Relevant tests or checks cover the generated Codex command
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Replace the removed Codex approval flag with the current supported non-interactive config override.
2. Extend the provider shell test to assert the Codex argv includes supported sandbox/approval options and excludes --ask-for-approval.
3. Run provider tests and update TASK-5 acceptance criteria/final notes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Changed scripts/providers/codex.sh to pass --config approval_policy="never" with --sandbox workspace-write. Added provider regression assertions for the removed flag, sandbox mode, and approval policy. Validation passed: bash scripts/test-providers.sh; npm test.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed the Codex provider command for current Codex CLI versions by replacing --ask-for-approval never with the supported approval_policy config override while keeping workspace-write sandboxing. Added regression coverage and verified with the provider test and full npm test suite.
<!-- SECTION:FINAL_SUMMARY:END -->
