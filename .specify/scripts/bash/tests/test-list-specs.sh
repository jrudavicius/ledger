#!/usr/bin/env bash

set -e
set -o pipefail

TEST_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_SPECS="$TEST_DIR/../list-specs.sh"
FIXTURE_ROOT=$(mktemp -d)
EMPTY_ROOT=$(mktemp -d)

cleanup() {
    rm -rf "$FIXTURE_ROOT" "$EMPTY_ROOT"
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

json_array_lines() {
    local key="$1"
    local document="$2"

    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$document" | jq -er ".${key}[]"
        return
    fi

    if command -v python3 >/dev/null 2>&1; then
        JSON_DOCUMENT="$document" python3 -c '
import json
import os
import sys

for value in json.loads(os.environ["JSON_DOCUMENT"])[sys.argv[1]]:
    print(value)
' "$key"
        return
    fi

    fail "tests require jq or python3 to parse JSON"
}

assert_equal() {
    local label="$1"
    local expected="$2"
    local actual="$3"
    if [[ "$actual" != "$expected" ]]; then
        printf 'FAIL: %s\nEXPECTED:\n%s\nACTUAL:\n%s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}

mkdir -p \
    "$FIXTURE_ROOT/.agents/skills/example" \
    "$FIXTURE_ROOT/.specify/memory" \
    "$FIXTURE_ROOT/.specify/templates" \
    "$FIXTURE_ROOT/architecture" \
    "$FIXTURE_ROOT/contexts/accounts" \
    "$FIXTURE_ROOT/dist" \
    "$FIXTURE_ROOT/docs/adr" \
    "$FIXTURE_ROOT/node_modules/example" \
    "$FIXTURE_ROOT/specs/001-alpha/contracts" \
    "$FIXTURE_ROOT/specs/002-beta/checklists" \
    "$FIXTURE_ROOT/specs/003-space name" \
    "$FIXTURE_ROOT/src"

printf '# Alpha\n' > "$FIXTURE_ROOT/specs/001-alpha/spec.md"
printf '{}\n' > "$FIXTURE_ROOT/specs/001-alpha/contracts/openapi.json"
printf '# Beta\n' > "$FIXTURE_ROOT/specs/002-beta/spec.md"
printf '# Checklist\n' > "$FIXTURE_ROOT/specs/002-beta/checklists/requirements.md"
printf '# Space\n' > "$FIXTURE_ROOT/specs/003-space name/spec.md"
printf '# Design\n' > "$FIXTURE_ROOT/specs/003-space name/Design Notes.md"
printf 'account: {}\n' > "$FIXTURE_ROOT/contexts/accounts/model.yaml"
printf '# Decision\n' > "$FIXTURE_ROOT/docs/adr/0001.md"
printf 'binary-shaped fixture\n' > "$FIXTURE_ROOT/docs/diagram.bin"
printf '# Constitution\n' > "$FIXTURE_ROOT/.specify/memory/constitution.md"
printf '# Architecture\n' > "$FIXTURE_ROOT/architecture/overview.mdx"
printf '# Project\n' > "$FIXTURE_ROOT/README.md"
printf 'domain notes\n' > "$FIXTURE_ROOT/src/domain-notes.txt"

printf '# Tooling\n' > "$FIXTURE_ROOT/.agents/skills/example/SKILL.md"
printf '# Template\n' > "$FIXTURE_ROOT/.specify/templates/spec-template.md"
printf '# Dependency\n' > "$FIXTURE_ROOT/node_modules/example/README.md"
printf '# Generated\n' > "$FIXTURE_ROOT/dist/README.md"
printf 'export const ignored = true;\n' > "$FIXTURE_ROOT/src/app.ts"

document=$(SPECIFY_INIT_DIR="$FIXTURE_ROOT" bash "$LIST_SPECS" --json)
actual_specs=$(json_array_lines SPEC_FILES "$document")
actual_support=$(json_array_lines SUPPORT_FILES "$document")

expected_specs=$(printf '%s\n' \
    "$FIXTURE_ROOT/specs/001-alpha/spec.md" \
    "$FIXTURE_ROOT/specs/002-beta/spec.md" \
    "$FIXTURE_ROOT/specs/003-space name/spec.md" | LC_ALL=C sort)

expected_support=$(printf '%s\n' \
    "$FIXTURE_ROOT/.specify/memory/constitution.md" \
    "$FIXTURE_ROOT/README.md" \
    "$FIXTURE_ROOT/architecture/overview.mdx" \
    "$FIXTURE_ROOT/contexts/accounts/model.yaml" \
    "$FIXTURE_ROOT/docs/adr/0001.md" \
    "$FIXTURE_ROOT/docs/diagram.bin" \
    "$FIXTURE_ROOT/specs/001-alpha/contracts/openapi.json" \
    "$FIXTURE_ROOT/specs/002-beta/checklists/requirements.md" \
    "$FIXTURE_ROOT/specs/003-space name/Design Notes.md" \
    "$FIXTURE_ROOT/src/domain-notes.txt" | LC_ALL=C sort)

assert_equal "canonical specs" "$expected_specs" "$actual_specs"
assert_equal "supporting context" "$expected_support" "$actual_support"

mkdir -p "$EMPTY_ROOT/.specify"
empty_document=$(SPECIFY_INIT_DIR="$EMPTY_ROOT" bash "$LIST_SPECS" --json)
assert_equal "empty repository JSON" '{"SPEC_FILES":[],"SUPPORT_FILES":[]}' "$empty_document"

printf 'PASS: list-specs discovers all canonical and supporting context\n'
