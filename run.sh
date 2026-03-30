#!/bin/bash
# Playwright E2E Test Generator Agent
# Usage: ./run.sh
# Or:    ./run.sh "RV2-12345"
# Or:    ./run.sh "paste your test plan here"

cd "$(dirname "$0")"

if [ -n "$1" ]; then
  claude --print "Input: $1"
else
  claude
fi
