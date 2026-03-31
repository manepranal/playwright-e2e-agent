#!/bin/bash
# Playwright E2E Test Generator Agent
# Usage: ./run.sh                          → interactive mode (recommended)
#        ./run.sh "RV2-12345"              → passes ticket ID directly (still interactive for Step 0 Q&A)
#        ./run.sh "paste your test plan"   → passes raw test plan directly

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOLT_DIR="${BOLT_DIR:-/Users/pranalmane/bolt}"

cd "$SCRIPT_DIR"

# Validate claude CLI is installed
if ! command -v claude &>/dev/null; then
  echo "ERROR: 'claude' CLI not found. Install it with:"
  echo "  npm install -g @anthropic-ai/claude-code"
  exit 1
fi

# Validate bolt project exists
if [ ! -d "$BOLT_DIR" ]; then
  echo "ERROR: bolt project not found at '$BOLT_DIR'."
  echo "Set the BOLT_DIR environment variable to override, e.g.:"
  echo "  BOLT_DIR=/path/to/bolt ./run.sh"
  exit 1
fi

if [ -n "$1" ]; then
  # NOTE: This mode passes the ticket/plan as the opening message but the agent
  # will still ask Step 0 questions interactively (branch, environment, feature flag).
  # For a truly non-interactive run you must include all three answers in the message.
  claude --message "Input: $1"
else
  claude
fi
