#!/usr/bin/env bash
# The build step of the release-images action (.github/actions/release-images,
# ADR-0012 of NFHotel): runs build-release-images.sh with the action's inputs, and with
# --push only when PUSH is 'true', so the action keeps its run block to one command
# (QC-YML-001 criterion 7).
#
# Env:   APP_PATH, APP_SHA, REGISTRY, PUSH, DEVOPS_SHA   the action inputs
#        GITHUB_STEP_SUMMARY                             set by the runner
# Usage: release-steps.sh
# Exit:  the exit code of build-release-images.sh
# Needs: bash 4+

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
args=(--app-dir "${APP_PATH:?}" --sha "${APP_SHA:?}" --devops-sha "${DEVOPS_SHA:?}" --registry "${REGISTRY:?}")
if [[ "${PUSH:-false}" == "true" ]]; then
  args+=(--push --output release.json --summary "${GITHUB_STEP_SUMMARY:-/dev/null}")
fi
exec bash "$ROOT/scripts/build-release-images.sh" "${args[@]}"
