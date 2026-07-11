#!/usr/bin/env bash

# Discover every feature specification and every repository knowledge artifact
# that can inform a specification. This command is intentionally independent of
# the active feature pointer.

set -e
set -o pipefail

JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            cat <<'EOF'
Usage: list-specs.sh [--json]

Recursively lists canonical specifications and their complete supporting context.
Canonical specifications are regular files named exactly spec.md under specs/.
Supporting context includes:
  - every other regular file under specs/
  - every regular file under contexts/, docs/, and .specify/memory/
  - documentation files elsewhere in the repository

Results are deduplicated, sorted by path, and do not depend on
.specify/feature.json. Tooling, dependencies, and generated output directories
are excluded from the repository-wide documentation scan.

OPTIONS:
  --json    Emit {"SPEC_FILES":[...],"SUPPORT_FILES":[...]} instead of text output
  --help    Show this help
EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root) || exit 1
SPECS_DIR="$REPO_ROOT/specs"
spec_files=()
support_files=()

if [[ -d "$SPECS_DIR" ]]; then
    spec_output=""
    if ! spec_output=$(find "$SPECS_DIR" -type f -name 'spec.md' -print | LC_ALL=C sort); then
        echo "ERROR: Failed to discover specifications under $SPECS_DIR" >&2
        exit 1
    fi

    while IFS= read -r spec_file; do
        [[ -n "$spec_file" ]] && spec_files+=("$spec_file")
    done <<< "$spec_output"
fi

emit_support_candidates() {
    local context_dir

    # Feature directories may contain contracts, checklists, research, plans,
    # data models, and other artifacts whose constraints must not be lost.
    if [[ -d "$SPECS_DIR" ]]; then
        find "$SPECS_DIR" -type f -print
    fi

    # These are the project's conventional homes for domain knowledge and
    # governance. Include every file so non-Markdown contracts and diagrams are
    # visible to the specification workflow too.
    for context_dir in "$REPO_ROOT/contexts" "$REPO_ROOT/docs" "$REPO_ROOT/.specify/memory"; do
        if [[ -d "$context_dir" ]]; then
            find "$context_dir" -type f -print
        fi
    done

    # Also find authored documentation outside the conventional roots. Prune
    # tool configuration, dependencies, caches, and generated output so their
    # bundled documentation cannot masquerade as project knowledge.
    find "$REPO_ROOT" \
        \( -type d \( \
            -name '.git' -o \
            -name '.agents' -o \
            -name '.codex' -o \
            -name '.specify' -o \
            -name 'node_modules' -o \
            -name 'vendor' -o \
            -name 'dist' -o \
            -name 'build' -o \
            -name 'coverage' -o \
            -name '.cache' -o \
            -name '.venv' \
        \) -prune \) -o \
        \( -type f \( \
            -iname '*.md' -o \
            -iname '*.mdx' -o \
            -iname '*.rst' -o \
            -iname '*.adoc' -o \
            -iname '*.txt' \
        \) -print \)
}

support_output=""
if ! support_output=$(emit_support_candidates | LC_ALL=C sort -u); then
    echo "ERROR: Failed to discover supporting specification context under $REPO_ROOT" >&2
    exit 1
fi

is_canonical_spec() {
    local candidate="$1"
    local spec_file
    for spec_file in "${spec_files[@]}"; do
        [[ "$candidate" == "$spec_file" ]] && return 0
    done
    return 1
}

while IFS= read -r support_file; do
    [[ -n "$support_file" ]] || continue
    if ! is_canonical_spec "$support_file"; then
        support_files+=("$support_file")
    fi
done <<< "$support_output"

json_array() {
    local item
    local json_items=""
    for item in "$@"; do
        json_items="${json_items}\"$(json_escape "$item")\","
    done
    printf '[%s]' "${json_items%,}"
}

if $JSON_MODE; then
    json_specs=$(json_array "${spec_files[@]}")
    json_support=$(json_array "${support_files[@]}")
    printf '{"SPEC_FILES":%s,"SUPPORT_FILES":%s}\n' "$json_specs" "$json_support"
else
    echo "SPEC_FILES:"
    for spec_file in "${spec_files[@]}"; do
        printf '  %s\n' "$spec_file"
    done
    echo "SUPPORT_FILES:"
    for support_file in "${support_files[@]}"; do
        printf '  %s\n' "$support_file"
    done
fi
