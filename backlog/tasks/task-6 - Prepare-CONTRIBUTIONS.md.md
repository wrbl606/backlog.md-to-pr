---
id: TASK-6
title: Prepare CONTRIBUTIONS.md
status: Done
assignee:
  - '@opencode'
created_date: '2026-06-25 14:38'
updated_date: '2026-06-25 15:52'
labels: []
dependencies: []
modified_files:
  - CONTRIBUTIONS.md
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
1. Inspect README, scripts, package.json to capture dev setup (Node 24 via mise, npm test runs provider/entrypoint tests). 2. Create CONTRIBUTIONS.md covering dev env setup, contribution workflow (feature branches/PRs/review), coding standards (bash set -euo pipefail, conventional commits), testing requirements (npm test / scripts/test-*.sh). 3. Verify file exists with expected sections. 4. Update task notes and check acceptance criteria.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created CONTRIBUTIONS.md in repo root covering: development environment (Node 24 via mise, npm install, npm test), project layout, contribution workflow (feature branches, PRs, review, Backlog.md task linking), coding standards (bash set -euo pipefail, provider adapter contract, docs updates), testing requirements (npm test runs scripts/test-*.sh, hermetic tests), conventional commit conventions, and PR expectations. Verified with npm test (all suites pass).
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added CONTRIBUTIONS.md at the repository root documenting development environment setup (Node 24, npm install, npm test), the contribution workflow (feature branches, PRs, review, Backlog.md task linking), coding standards (bash set -euo pipefail, provider adapter contract, docs updates), testing requirements (hermetic scripts/test-*.sh run by npm test), conventional commit conventions, and PR expectations. Verified with npm test (provider, load-backlog, entrypoint-opencode suites all pass).
<!-- SECTION:FINAL_SUMMARY:END -->
