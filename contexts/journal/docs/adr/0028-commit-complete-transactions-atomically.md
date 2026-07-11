# Commit Complete Transactions Atomically

Journal Commit is the successful atomic append of one complete Journal change set at one Ledger Position. Every new Transaction in that change set includes all of its authoritative Posting facts, and a Posting cannot be independently accepted or appended. Direct acceptance contains one new Transaction; Transaction Resolution may atomically transition its original and add complete Posted settlement and Continuation Transactions. Any validation, concurrency, or persistence failure appends none of the change set.

Account activity indexes, Posted Balance, pending totals, and directional capacities are derived from complete committed Transactions rather than independently authoritative Posting writes.

## Consequences

This decision fixes the domain atomicity boundary. Journal History is logically partitioned by Ledger, while the initial implementation uses one shared ACID write transaction to keep evaluated Accounts facts valid through Journal Commit. Physical tables, segments, shards, and applicable Controls coordination remain separate decisions.
