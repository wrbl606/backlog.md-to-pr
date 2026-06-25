---
id: TASK-4
title: Fix OpenCode Go entrypoint run
status: Done
assignee:
  - '@codex'
created_date: '2026-06-25 11:47'
updated_date: '2026-06-25 12:04'
labels: []
dependencies: []
priority: high
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The action command using provider=opencode with an OpenCode Go model fails locally and in CI. The entrypoint should run the OpenCode provider path reliably with repository-local Backlog loading, prompt generation, and provider execution.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The provided OpenCode command reaches the provider invocation without shell or action wiring failures
- [x] #2 OpenCode Go subscription auth is passed in the format expected by the OpenCode CLI
- [x] #3 Regression tests cover the failing provider/entrypoint path
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reproduce the command path with safe local stubs so secrets and network calls are not used.\n2. Identify whether failure is in Backlog loading, OpenCode auth/config, provider invocation, or git/PR creation wiring.\n3. Patch the smallest affected scripts and add regression coverage.\n4. Run the project tests plus a targeted entrypoint dry run.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Identified the OpenCode failure as a stale provider prefix: OpenCode 1.17.10 exposes subscription models under opencode/... and rejects opencode-go/.... Added adapter normalization from opencode-go/... to opencode/... with a deprecation warning. The entrypoint regression also exposed that runtime prompt/task files were written inside the checkout and could be committed; moved the default runtime directory to RUNNER_TEMP/TMPDIR. Added provider and entrypoint dry-run coverage. Validation passed: npm test.

Reopened after user reported the OpenCode Go subscription key does not authorize opencode/... models. Revising the provider mapping so OpenCode Go credentials and models stay on the correct provider id instead of normalizing to opencode/... blindly.

Corrected the prior model-prefix fix: OpenCode Go subscription credentials must be stored under auth["opencode-go"] and opencode-go/... models must be preserved. If an OpenCode Go key is provided with an opencode/... model, the adapter now rewrites it to opencode-go/... instead of the reverse. Verified the real OpenCode binary reports the credential as OpenCode Go api, and npm test passes.

Reopened after user reported OpenCode prints 'zsh:1: command not found: backlog' when following the generated Backlog workflow instructions. The provider process needs a backlog command on PATH, not just the action loader's internal npx resolution.

Added a runtime backlog shim after load-backlog.sh succeeds and before hooks/provider execution. The shim is prepended to PATH for provider subprocesses and resolves backlog through npx --no-install from GITHUB_WORKSPACE, falling back to the original global backlog binary if present. Updated the OpenCode entrypoint regression so the fake provider runs backlog instructions overview, reproducing the prior command-not-found failure. Validation passed: npm test.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed the OpenCode provider runtime environment by adding a backlog PATH shim for provider subprocesses, preserving the corrected OpenCode Go credential/model pairing, and covering the missing-command failure in the entrypoint test. Verified with npm test.
<!-- SECTION:FINAL_SUMMARY:END -->
