#!/usr/bin/env bash
#
# Watch nekotrix/SVT-AV1-Essential for new commits and update the pin file.
#
# - Resolves the newest commit on the upstream branch. When UPSTREAM_REF is
#   empty, the highest-numbered Essential-v* branch is selected automatically
#   (upstream renames these branches on version bumps, e.g. Essential-v4.3.0
#   -> Essential-v4.3.1).
# - Compares the commit against upstream-pin.json and rewrites the pin when
#   anything changed.
# - Emits changed=true only when the pinned commit itself is new, so the
#   caller can trigger a rebuild exactly once per upstream commit.
#
# Environment:
#   UPSTREAM_REPO    upstream repository         (default nekotrix/SVT-AV1-Essential)
#   UPSTREAM_REF     branch/tag/commit to follow (default: auto-detect latest Essential-v* branch)
#   DRY_RUN          1 to skip writing the pin file

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM_REPO="${UPSTREAM_REPO:-nekotrix/SVT-AV1-Essential}"
UPSTREAM_REF="${UPSTREAM_REF:-}"
DRY_RUN="${DRY_RUN:-0}"

PIN_FILE="$ROOT_DIR/upstream-pin.json"

log() {
    printf '%s\n' "$*" >&2
}

die() {
    log "error: $*"
    exit 1
}

need() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

need gh
need jq
need git

if [[ -z "$UPSTREAM_REF" ]]; then
    UPSTREAM_REF="$(
        gh api "repos/${UPSTREAM_REPO}/branches" --paginate --jq '.[].name' \
            | grep -E '^Essential-v[0-9]' \
            | sort -V \
            | tail -n 1
    )"
    [[ -n "$UPSTREAM_REF" ]] || die "no Essential-v* branch found in ${UPSTREAM_REPO}"
    log "Auto-selected latest upstream branch: ${UPSTREAM_REF}"
fi

read -r COMMIT COMMIT_DATE < <(
    gh api "repos/${UPSTREAM_REPO}/commits/${UPSTREAM_REF}" \
        --jq '[.sha, .commit.committer.date] | @tsv'
)
[[ -n "$COMMIT" ]] || die "could not resolve ${UPSTREAM_REPO}@${UPSTREAM_REF}"

SHORT_COMMIT="${COMMIT:0:12}"

log "Upstream : ${UPSTREAM_REPO}@${UPSTREAM_REF}"
log "Commit   : ${COMMIT} (${COMMIT_DATE})"

CURRENT_SHA=""
if [[ -f "$PIN_FILE" ]]; then
    CURRENT_SHA="$(jq -r '.sha // empty' "$PIN_FILE")"
fi

CHANGED=true
if [[ -n "$CURRENT_SHA" && "$CURRENT_SHA" == "$COMMIT" ]]; then
    CHANGED=false
    log "Pinned commit already matches upstream"
else
    log "New upstream commit: ${CURRENT_SHA:-<none>} -> ${COMMIT}"
fi

CANDIDATE="$(jq -n \
    --arg repo "$UPSTREAM_REPO" \
    --arg ref "$UPSTREAM_REF" \
    --arg sha "$COMMIT" \
    --arg date "$COMMIT_DATE" \
    '{repo: $repo, ref: $ref, sha: $sha, date: $date}')"

PIN_CHANGED=true
if [[ -f "$PIN_FILE" ]] && printf '%s\n' "$CANDIDATE" | cmp -s - "$PIN_FILE"; then
    PIN_CHANGED=false
    log "Pin file is already up to date"
fi

if [[ "$PIN_CHANGED" == "true" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
        log "DRY_RUN: not writing ${PIN_FILE#"$ROOT_DIR"/}"
        printf '%s\n' "$CANDIDATE" | sed 's/^/    /' >&2
    else
        printf '%s\n' "$CANDIDATE" >"$PIN_FILE"
        log "Updated ${PIN_FILE#"$ROOT_DIR"/}"
    fi
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
        echo "changed=${CHANGED}"
        echo "pin_changed=${PIN_CHANGED}"
        echo "repo=${UPSTREAM_REPO}"
        echo "ref=${UPSTREAM_REF}"
        echo "version=${SHORT_COMMIT}"
        echo "commit=${COMMIT}"
    } >>"$GITHUB_OUTPUT"
fi

log "Done: ${UPSTREAM_REPO}@${SHORT_COMMIT} (changed=${CHANGED})"