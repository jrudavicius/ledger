#!/usr/bin/env bash

# Discover every feature specification in the repository.
# This command is intentionally independent of the active feature pointer.

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

Recursively lists every regular file named exactly spec.md under specs/.
Results are sorted by path and do not depend on .specify/feature.json.

OPTIONS:
  --json    Emit {"SPEC_FILES":[...]} instead of text output
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

if $JSON_MODE; then
    if has_jq; then
        if [[ ${#spec_files[@]} -eq 0 ]]; then
            jq -cn '{SPEC_FILES:[]}'
        else
            json_specs=$(printf '%s\n' "${spec_files[@]}" | jq -R . | jq -s .)
            jq -cn --argjson specs "$json_specs" '{SPEC_FILES:$specs}'
        fi
    else
        if [[ ${#spec_files[@]} -eq 0 ]]; then
            json_specs="[]"
        else
            json_specs=$(for spec_file in "${spec_files[@]}"; do
                printf '"%s",' "$(json_escape "$spec_file")"
            done)
            json_specs="[${json_specs%,}]"
        fi
        printf '{"SPEC_FILES":%s}\n' "$json_specs"
    fi
else
    echo "SPEC_FILES:"
    for spec_file in "${spec_files[@]}"; do
        printf '  %s\n' "$spec_file"
    done
fi
