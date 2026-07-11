# Transfer Limits Feature Brief

> [!status]
> Approved input for a future `speckit-specify` run.
> This is not yet a feature specification or an implementation plan.

## Intent

Prevent an outward transfer from being accepted when its measured amount exceeds either a per-action maximum or the remaining allowance in an applicable calendar-day or calendar-month limit. Limit decisions must remain correct under concurrent requests and idempotent retries and must be auditable without treating an analytical warehouse as authoritative state.

## Domain Framing

- The limited behavior is the product-owned Controlled Action that first accepts an outward transfer. It is not an arbitrary Ledger Transaction: one transfer may later produce Pending, Posted, continuation, fee, correction, or settlement activity.
- The operation-owning context supplies and validates the measured transfer amount. Controls must not infer it by summing Ledger Postings or balance changes.
- The default measure is the positive beneficiary principal in exactly one source Asset, expressed in exact minor units and excluding fees. Ledger availability still evaluates the complete accounting effect, including fees.
- The recommended initial Control Target is the Product Arrangement. Customer-wide usage across several arrangements requires an explicit domain extension and is not inferred through warehouse joins.

## In Scope

One accepted outward-transfer action is subject to three independent rules:

1. A maximum amount for the individual action.
2. A cumulative Usage Limit for an explicit calendar-day Limit Window.
3. A cumulative Usage Limit for an explicit calendar-month Limit Window.

Every applicable rule must pass in one Control Evaluation. Passing one rule never compensates for failing another.

## Decided Behavior

- A candidate is allowed at the exact threshold. It is denied only when its amount exceeds the per-action maximum or recognized usage plus its amount exceeds a window maximum.
- Daily and monthly usage are independent. Starting a new day does not reset monthly usage.
- All applicable limits are evaluated against authoritative state that remains valid through acceptance. Concurrent candidates cannot both consume the same remaining allowance.
- Acceptance of the outward-transfer action and recognition of every applicable daily and monthly usage contribution succeed or fail together. If any Control or Ledger invariant denies the action, no limit contribution is recognized.
- Usage is recognized when the action is first authoritatively accepted, including acceptance as Pending. Service acceptance time selects the windows; caller request time and Ledger Effective At do not.
- Limit Windows are half-open intervals `[start, end)` defined by an explicit calendar rule and IANA time zone. An action accepted exactly at the end belongs to the next window.
- The default Usage Basis is Gross Accepted Usage. A later void, reversal, correction, settlement failure, or inbound refund does not restore allowance or move usage to another window.
- Settlement, resolution, continuation, and other Ledger activity for the same unchanged business action do not consume the limits again.
- An idempotent retry returns the original logical outcome and never consumes usage twice. Reusing an accepted action identity with changed content is a conflict.
- A limit rejection recognizes no usage. Repeating the same rejected action identity returns its stable original outcome; a genuinely new attempt uses a new identity.
- An amount-based limit names exactly one Asset. The first version performs no implicit currency conversion or cross-Asset aggregation.
- Limit activation and adjustment are prospective. Tightening a threshold below already recognized usage does not invalidate accepted actions; it denies further matching actions until sufficient headroom exists in an applicable window.
- A warehouse may report accepted usage and settled transfer volume, but no warehouse or other eventually consistent projection participates in transfer authorization.

## Acceptance Examples

1. **Per-action boundary**: Given a per-action maximum of EUR 700 and sufficient daily and monthly headroom, EUR 700 is accepted and EUR 700.01 is denied.
2. **Combined windows**: Given EUR 400 daily usage, EUR 4,300 monthly usage, a EUR 1,000 daily maximum, and a EUR 5,000 monthly maximum, a EUR 600 candidate may be accepted and results in EUR 1,000 daily and EUR 4,900 monthly usage.
3. **Atomic failure**: Given enough daily headroom but insufficient monthly headroom, the candidate is denied and neither counter changes.
4. **Concurrency**: Given EUR 400 daily usage and EUR 600 remaining, two concurrent EUR 600 candidates cannot both be accepted; at most one recognizes usage.
5. **Idempotency**: Repeating an accepted EUR 100 action with the same identity returns the original result and leaves usage increased by exactly EUR 100.
6. **Calendar boundary**: A request received before midnight but accepted at or after midnight belongs to the new calendar-day window.
7. **Gross accepted basis**: Voiding or reversing an accepted transfer does not reduce its original daily or monthly usage.
8. **Projection lag**: A delayed warehouse projection has no effect on whether a candidate is accepted or denied.

## Open Questions for Specification

### Per-action limit ownership

Choose where the individual-action maximum belongs:

- Add an `Action Amount Limit` as a fourth typed Control Constraint when the maximum is an independently imposed, adjustable, auditable operational or risk Control; or
- model it as an Arrangement Term when it is an intrinsic entitlement of the financial product.

Do not represent it as a synthetic one-action Limit Window. The canonical Controls model currently defines a closed three-constraint union, so selecting the first option requires an explicit domain decision that reconciles Controls ADR-0009.

### Usage scope

The recommended first version limits one Product Arrangement. If the required business rule is Customer-wide across multiple arrangements, the specification must explicitly add an appropriate Control Target or usage subject. It must not reconstruct that scope from analytical joins during authorization.

## Non-Goals for the First Version

- Rolling 24-hour or rolling-month windows.
- Cross-Asset valuation, FX-rate selection, or reference-currency limits.
- Customer-wide aggregation unless selected explicitly during specification.
- Inferring transfer semantics from Ledger Postings.
- Using warehouse totals, reconciliation views, or Balance projections as authoritative usage.
- Selecting database, deployment, aggregate, or event-stream topology in the feature specification.

## Planning Constraints

- Present one transfer-acceptance interface to callers. Do not expose a race-prone `check limits -> post Transaction -> record usage` workflow.
- Preserve the repository decision that write-side Domain Events are authoritative and query projections are rebuildable.
- The preferred first implementation is one authoritative commit covering the accepted action, Ledger activity, applicable Limit Usage, idempotency outcome, and downstream publication. If the participating contexts must use independently committed stores, planning must introduce a durable reservation protocol that preserves the same all-or-nothing behavior.
- A downstream warehouse may project transfer, Ledger, and Controls events for reporting, investigation, reconciliation, and anomaly detection.

## Canonical References

- [Context Map](../../CONTEXT-MAP.md)
- [Controls ubiquitous language](../../contexts/controls/CONTEXT.md)
- [Controls conceptual model](../../contexts/controls/Controls%20Model.md)
- [Use Typed Controls for Operational Constraints](../../contexts/controls/docs/adr/0009-use-typed-controls-for-operational-constraints.md)
- [Products ubiquitous language](../../contexts/products/CONTEXT.md)
- [Accounts ubiquitous language](../../contexts/accounts/CONTEXT.md)
- [Journal ubiquitous language](../../contexts/journal/CONTEXT.md)
- [Balances ubiquitous language](../../contexts/balances/CONTEXT.md)
- [Shared language](../../SHARED-LANGUAGE.md)
- [Use CQRS and Event-Sourced Write Models](../adr/0009-use-cqrs-and-event-sourced-write-models.md)

## Future Specify Invocation

When implementation is ready, invoke the skill with this input:

```text
$speckit-specify Create the Transfer Limits feature specification. First read
docs/feature-briefs/transfer-limits.md and treat its Decided Behavior as fixed
feature input. Reconcile terminology with the canonical references listed in
that brief. Preserve its scope and non-goals. Turn only items under Open
Questions for Specification into clarification markers. Do not treat warehouse
or other eventually consistent projections as authoritative limit state.
```

The Specify run should create the numbered feature directory, its `spec.md`, and its requirements checklist at that time. This brief must not change `.specify/feature.json` before then.
