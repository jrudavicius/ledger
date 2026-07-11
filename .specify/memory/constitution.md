<!--
Sync Impact Report
Version change: unratified template -> 1.0.0
Modified principles:
- Template principle 1 -> I. Code Quality Is Non-Negotiable
- Template principle 2 -> II. Tests Define Acceptable Change
- Template principle 3 -> III. User Experience Stays Consistent
- Template principle 4 -> IV. Performance Budgets Are Requirements
Added sections:
- Engineering Standards
- Development Workflow & Quality Gates
Removed sections:
- Template principle 5 placeholder
Templates requiring updates:
- ✅ .specify/templates/plan-template.md
- ✅ .specify/templates/spec-template.md
- ✅ .specify/templates/tasks-template.md
- ✅ .specify/templates/commands/*.md (directory absent; no command files to update)
- ✅ README.md / docs / runtime guidance (not present in repository)
Follow-up TODOs: None
-->
# Ledger Constitution

## Core Principles

### I. Code Quality Is Non-Negotiable

Production code MUST be cohesive, readable, and organized around clear module
boundaries. Public interfaces MUST express domain intent and hide implementation
detail. Each change MUST preserve existing behavior unless the specification
explicitly changes it. Dead code, speculative abstractions, and duplicated
business rules MUST be removed or justified in the implementation plan.
Formatting, linting, static analysis, and review MUST pass before release.

Rationale: durable code quality keeps the project cheap to change and makes
future defects easier to localize.

### II. Tests Define Acceptable Change

Every feature and bug fix MUST include automated tests that fail before
implementation, or an explicit reviewed exception that documents why automation
is impractical and what manual evidence replaces it. Tests MUST cover
user-story acceptance behavior, important edge cases, and integration
boundaries. Regressions MUST add a failing test that reproduces the defect.
Tests MUST be deterministic and runnable by a maintainer without private local
state.

Rationale: tests are the executable contract that prevents regressions and
keeps refactoring safe.

### III. User Experience Stays Consistent

User-facing behavior MUST follow existing product patterns for copy,
navigation, interaction states, accessibility, and error recovery. New UI
components, labels, or flows MUST reuse existing conventions unless the
specification documents a user-centered reason for a new pattern. Specifications
MUST define empty, loading, success, and error states for affected user flows.
Acceptance criteria MUST be stated from the user's perspective.

Rationale: consistent UX reduces cognitive load and makes the product feel like
one system instead of a set of isolated features.

### IV. Performance Budgets Are Requirements

Each feature MUST define measurable performance budgets for user-visible
latency, throughput, resource usage, render time, or update time. A feature may
declare "not performance-sensitive" only when the plan explains why no
performance-sensitive path changes. Implementations MUST preserve or improve
approved budgets. Any regression MUST include explicit approval, a mitigation
task, and measurement evidence from profiling, benchmarking, or production-like
testing.

Rationale: performance is part of user experience and cannot be recovered
reliably after design and implementation choices are already locked in.

## Engineering Standards

- Code MUST prefer simple control flow, explicit names, and small interfaces
  over cleverness or broad abstractions.
- Domain rules MUST live in one authoritative place. Duplicated rules require a
  documented reason and a follow-up consolidation task.
- Error handling MUST make failures actionable for users or operators. Silent
  failure is prohibited.
- Dependencies MUST be justified by concrete value, maintenance posture, and
  performance impact.
- Accessibility requirements MUST be treated as functional requirements for
  user-facing features.
- Observability MUST be added for new critical paths so defects and performance
  regressions can be diagnosed from logs, metrics, traces, or equivalent
  evidence available in the project stack.

## Development Workflow & Quality Gates

- Specifications MUST include independently testable user stories, measurable
  success criteria, UX state expectations, and performance requirements or an
  explicit non-applicability statement.
- Implementation plans MUST pass the Constitution Check before research and
  again after design. Any violation MUST be documented with a simpler
  alternative considered and rejected.
- Task plans MUST include test tasks before implementation tasks for each user
  story, plus quality, UX, and performance validation tasks where applicable.
- Reviews MUST verify code quality, test evidence, UX consistency, and
  performance evidence before merge or release.
- A feature is not complete until its tests and agreed quality gates pass in the
  same environment used for handoff.

## Governance

This constitution supersedes lower-level practices when conflicts occur.
Amendments require a documented rationale, an impact review for templates and
active specs, and an update to this file's Sync Impact Report.

Versioning follows semantic versioning:

- MAJOR: backward-incompatible governance changes, principle removals, or
  redefinitions of mandatory standards.
- MINOR: new principles, new mandatory sections, or materially expanded
  guidance.
- PATCH: clarifications, wording fixes, and non-semantic refinements.

Compliance is reviewed during planning, task generation, implementation review,
and release readiness. Exceptions MUST identify the violated principle, reason,
owner, expiration condition, and follow-up task.

**Version**: 1.0.0 | **Ratified**: 2026-07-11 | **Last Amended**: 2026-07-11
