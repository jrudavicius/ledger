# Partition Journal History by Ledger

Each Ledger owns one authoritative Journal History: a logical append-only sequence of complete Journal Commits totally ordered by Ledger Position. A Transaction's immutable content and complete Posting set are introduced exactly once in that history. Later commits may append lifecycle transitions, corrections, resolutions, and explicit links without rewriting the original content.

Per-Account activity streams, indexes, balance views, reconciliation views, and write snapshots are derived from Journal History rather than duplicate authoritative histories.

## Consequences

Cross-Ledger Transactions remain impossible because one Journal Commit belongs to one Ledger History. A multi-Account or multi-Asset Transaction remains one complete atomic change inside that Ledger.

The logical partition does not require one file, table, process, event-stream aggregate, or physical shard per Ledger. Storage may segment or shard the history only while preserving complete Journal Commit atomicity and Ledger Position order.
