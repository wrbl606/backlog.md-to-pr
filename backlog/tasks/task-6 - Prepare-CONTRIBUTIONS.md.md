---
id: TASK-6
title: Prepare CONTRIBUTIONS.md
status: Done
assignee:
  - '@opencode'
created_date: '2026-06-25 14:38'
updated_date: '2026-06-25 14:42'
labels: []
dependencies: []
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a CONTRIBUTIONS.md file that explains how to contribute to the project. The file should cover contribution workflow, development setup, coding standards, and pull request expectations.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 CONTRIBUTIONS.md exists in the repository root
- [x] #2 Explains how to set up a development environment
- [x] #3 Describes the process for submitting changes (feature branches, PRs, review)
- [x] #4 References coding standards, testing requirements, and commit conventions where applicable
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Inspect repo (README, action.yml, scripts, tests, package.json, git log) to gather accurate dev setup, test, and commit-convention facts. 2. Create CONTRIBUTIONS.md at repo root covering: dev environment setup, contribution workflow (feature branches, PRs, review), coding standards, testing requirements, commit conventions. 3. Run npm test to verify nothing breaks. 4. Check acceptance criteria and finalize task.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created CONTRIBUTIONS.md at repository root with sections: Development Environment Setup (Node 24 via mise, npm install, gh CLI, provider creds), Running Tests (npm test runs the three bash test scripts), Project Layout, Coding Standards (bash set -euo pipefail, no direct Backlog.md edits, hook scripts), Testing Requirements (add/keep test-*.sh passing), Commit Conventions (Conventional Commits: feat/fix/docs/chore/task), Contribution Workflow (search/create Backlog task, feature branch, npm test, conventional commit, PR referencing task ID, review, finalize). Verified with npm test: provider tests passed, load-backlog tests passed, entrypoint opencode tests passed.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added CONTRIBUTIONS.md to the repository root documenting development environment setup (Node 24 via mise, npm install, GitHub CLI, optional provider credentials), the contribution workflow (Backlog.md task search/creation, feature branches, PRs referencing task IDs, review, finalization), coding standards (bash set -euo pipefail, Backlog.md CLI-only edits, hook script discipline), testing requirements (npm test suite of bash scripts, failure-exit behavior), and Conventional Commits conventions matching existing history. Verified by running npm test, which passed all three test scripts.
<!-- SECTION:FINAL_SUMMARY:END -->
