# Separate Ledger Position from Recorded Time

Every committed mutation scoped to a Ledger receives an immutable Ledger Position that totally orders committed mutations within that Ledger. Recorded At remains the service-assigned wall-clock instant and may repeat, so it never resolves concurrency, replay order, or audit order. Effective At remains the economic reporting time.

Ledger Position is a Ledger-scoped domain concept. It need not be consecutive or exposed as a numeric value and may reuse or be encoded by the event store's global commit position. The public Consistency Position remains opaque and may carry the broader global coordinate needed by cross-context projections. Historical balance queries may use Known Through for an exact Ledger Position prefix or Known At for a wall-clock cutoff, but never both.

Rejected or failed commands append no Domain Event and therefore create no new Ledger Position, even when their stable outcome consumes an Idempotency Key and their attempt is audited.

## Consequences

Account policy changes, Transaction acceptance, Journal replay, and derived balance reconstruction use Ledger Position order. Recorded At precision is not part of concurrency correctness. The initial shared ACID write boundary orders Accounts changes with Journal Commit; ordering applicable Controls decisions remains a separate protocol decision.
