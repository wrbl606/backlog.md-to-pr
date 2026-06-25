---
id: TASK-3
title: Use local Backlog CLI via npx
status: Done
assignee:
  - '@codex'
created_date: '2026-06-25 11:31'
updated_date: '2026-06-25 11:32'
labels: []
dependencies: []
modified_files:
  - scripts/load-backlog.sh
  - scripts/test-load-backlog.sh
  - package.json
  - action.yml
  - README.md
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The action can fail locally or in CI with 'Backlog.md CLI was not found after installation' when the backlog binary is not on PATH even though backlog.md is installed as a project dependency. The action should support invoking the locally installed Backlog.md CLI through npx.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Backlog loading works when only the project-local backlog.md package is installed
- [x] #2 The default install/lookup path uses npx without requiring a global backlog binary
- [x] #3 Tests or checks cover the Backlog CLI invocation path
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Resolve the Backlog CLI through npx --no-install before falling back to a global backlog binary.
2. Use the resolved command for task loading and workflow-instruction loading.
3. Add a stubbed loader regression test and update docs for the resolution order.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented Backlog CLI resolution through npx --no-install backlog before falling back to a global backlog binary. Added a loader test that stubs npx and verifies task and workflow instruction loading without a backlog executable on PATH. Validation passed: npm test.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated the Backlog loader to invoke a locally installed Backlog.md CLI through npx --no-install backlog, then fall back to a global backlog binary or the configured install command. Added regression coverage and documented the new lookup order.
<!-- SECTION:FINAL_SUMMARY:END -->
