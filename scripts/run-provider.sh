#!/usr/bin/env bash
set -euo pipefail

provider="${BACKLOG_TO_PR_PROVIDER:-codex}"
adapter="$BACKLOG_TO_PR_ACTION_PATH/scripts/providers/$provider.sh"

if [[ ! -f "$adapter" ]]; then
  echo "backlog-to-pr: unsupported provider '$provider'. Expected adapter at $adapter" >&2
  exit 1
fi

bash "$adapter" install
bash "$adapter" run
