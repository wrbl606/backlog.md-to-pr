---
id: TASK-8
title: Add option to tag the person triggering the workflow in the PR
status: Done
assignee: []
created_date: '2026-06-25 16:01'
updated_date: '2026-06-25 17:01'
labels:
  - enhancement
dependencies: []
references:
  - action.yml
  - scripts/entrypoint.sh
  - .github/workflows/backlog-to-pr.yml
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
When a user manually triggers the workflow via workflow_dispatch, there should be an option to automatically tag them in the resulting pull request — either by @mentioning them in the PR body or assigning them as the PR assignee.

The current workflow has no awareness of who triggered it. Adding a new input parameter (e.g. 'tag-trigger') would let users opt in to having the triggering actor tagged.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A new boolean input 'tag-trigger' is added to action.yml, defaulting to false
- [x] #2 When enabled, the PR body includes an @mention of the github.actor who triggered the workflow
- [x] #3 The @mention appears in the PR body below the main content as a note
- [x] #4 Behavior is documented in README.md including the new input
- [x] #5 The workflow file (.github/workflows/backlog-to-pr.yml) exposes the new input
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added tag-trigger boolean input to action.yml (default false). When enabled, appends 'Triggered by @{actor}' to the PR body. Exposed in workflow_dispatch inputs and env passthrough.
<!-- SECTION:FINAL_SUMMARY:END -->
