---
status: accepted
---

# Use CQRS and Event-Sourced Write Models

The service will separate state-changing commands from queries and use immutable Domain Events as the authoritative history of every stateful bounded context. Command handlers will rebuild the relevant consistency boundary from its event stream, decide against that state, and append versioned events with optimistic concurrency; queries will use dedicated, rebuildable read models. This is chosen over mutable domain records plus a parallel audit log so financial state, corrections, operator actions, and historical explanations have one authoritative change history rather than two histories that can diverge.

## Consequences

- Domain event streams are authoritative. Read models, indexes, and write-side snapshots are derived data and may be discarded and rebuilt; a snapshot is only a replay optimization and is distinct from a Ledger Balance Snapshot.
- Commands express semantic intent and never use an eventually consistent query projection to enforce an invariant. Each Ledger owns one logical authoritative Journal History ordered by Ledger Position. The initial implementation uses one ACID write transaction across Accounts and Journal to verify every evaluated Account Revision and append one complete Journal change set; every new Transaction contains its full Posting set and no Posting is independently accepted. Physical storage segmentation and applicable Controls coordination remain separate decisions.
- Every event has an immutable event identifier, event type and schema version, stream identifier and revision, global commit position, Organization and Ledger scope where applicable, action, command, correlation, causation, and change-set identifiers, actor context, recorded time, effective time where meaningful, and an explicitly audit-safe payload.
- Domain Events and audit attempts remain different concepts. Successful mutations atomically persist their events, idempotency outcome, completed Action Record, and the audit-safe information needed to materialize State Change Records. Reads and rejected or failed commands create an Action Record but append no Domain Event. Searchable State Change Records are rebuildable audit representations of committed events, not a second source of domain state.
- Command results expose the committed global position as a consistency token. Query models expose the position through which they are current and can satisfy a caller-provided minimum position or return a clear not-yet-current outcome; undetectably stale read-after-write results are not acceptable.
- Event contracts are immutable once written. Schema evolution uses new versions and deterministic upcasting or equivalent compatibility logic, and replay, idempotency, optimistic-concurrency, projection recovery, and full-rebuild equivalence are required test concerns.
