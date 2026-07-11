# Co-locate Accounts and Journal Writes Initially

The initial implementation enforces Account Revision Fence and Journal Commit in one ACID write transaction spanning the authoritative Accounts and Journal stores. A change set touching several Accounts reads or locks their authoritative revisions in deterministic Account ID order, validates the complete decision, and appends one commit to the Ledger's Journal History only when every revision remains current.

The same database transaction durably preserves the complete Transaction and Posting facts, Ledger Position and global commit coordinate, consumed Idempotency Key outcome, Domain Events, completed Action Record, and audit-safe material needed for derived State Change Records. Failure commits none of them.

## Consequences

Accounts and Journal remain separate bounded contexts with separate language and ownership. Sharing a transactional write boundary does not merge them and does not require their read models or APIs to be co-located.

Asynchronous event choreography cannot authorize money movement in the initial implementation. Events published after commit may update projections and integrations but cannot retroactively determine whether the Transaction was accepted.

A future distributed reservation or compare-and-swap protocol may replace the shared transaction only if it preserves the same all-or-nothing revision fencing, idempotency, Journal atomicity, and audit outcome. Applicable Controls coordination is deferred to the Controls redesign.
