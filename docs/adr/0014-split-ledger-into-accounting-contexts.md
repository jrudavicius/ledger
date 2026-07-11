# Split Ledger into Accounts, Journal, and Balances Contexts

The former Ledger bounded context combined Account identity and lifecycle, authoritative Transaction recording, and derived balance query language behind one broad model. Split it into Accounts, Journal, and Balances bounded contexts so each owns one coherent language and responsibility: Accounts owns Account policy and lifecycle, Journal owns Ledgers and authoritative Transaction acceptance, and Balances owns rebuildable query views.

## Consequences

- Journal decides against authoritative Accounts facts at explicit Account Revisions and fences every affected revision through Journal Commit; it never authorizes through Balances projections. Applicable Controls coordination remains a separate protocol decision.
- Account closure requires authoritative Journal eligibility plus Products and Controls evidence. The cross-context ordering protocol remains a separate design decision.
- Shared operation identity, Recorded At, and Ledger Position language remain system-wide rather than being redefined independently across the three contexts.
- This decision chooses language and ownership boundaries, not deployment units, storage schemas, aggregate roots, or event-stream topology.
