---
id: TASK-2
title: Fix workflow prompt handling for provider CLI
status: Done
assignee:
  - '@codex'
created_date: '2026-06-25 11:12'
updated_date: '2026-06-25 11:22'
labels: []
dependencies: []
modified_files:
  - scripts/providers/opencode.sh
  - scripts/test-providers.sh
  - package.json
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The backlog-to-pr GitHub Action fails during the Run backlog-to-pr step with 'File not found: Follow the instructions in the attached backlog-to-pr prompt.' because the provider CLI appears to treat the prompt text as a file path. The action should pass the generated backlog-to-pr instructions to the selected provider in the format that provider expects.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The action no longer passes plain prompt text to provider CLIs as a file path
- [x] #2 Codex workflow execution receives the generated backlog-to-pr prompt content
- [x] #3 Tests or checks cover the corrected command construction
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Inspect provider wrappers and current CLI help to identify how generated prompts should be passed.
2. Fix OpenCode invocation so prompt content is the run message, not a file attachment consumed by --file.
3. Add regression coverage for provider command construction and run it locally.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Verified current OpenCode 1.17.10 help: opencode run accepts positional message text and --file is for attachments. Verified Codex 0.142.2 exec reads stdin when '-' is supplied. Implemented OpenCode prompt-content invocation and added stubbed provider tests. Validation passed: npm test.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Changed the OpenCode adapter to read BACKLOG_TO_PR_PROMPT and pass its contents as the opencode run message instead of using --file plus a short placeholder prompt. Added npm test coverage that stubs OpenCode and Codex to verify command construction and prompt delivery.
<!-- SECTION:FINAL_SUMMARY:END -->
