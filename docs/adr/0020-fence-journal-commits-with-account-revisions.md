# Fence Journal Commits with Account Revisions

Accounts exposes an opaque current Account Revision for every Account. The revision identifies one authoritative version of the Account's identity, lifecycle, and policy facts and advances whenever any authoritative Account fact changes.

Journal evaluates every affected Account at a specific Account Revision. Journal Commit atomically verifies that all evaluated revisions remain current, records the revision map with the complete change set and each newly accepted Transaction, and appends the change set only when every fence succeeds. Any mismatch invalidates the entire decision for re-evaluation; no Posting, lifecycle transition, or partial Account activity is accepted.

## Consequences

Account Revision is an Accounts-owned internal concurrency token, not necessarily a client-supplied expected revision. Recording it explains exactly which Account facts authorized a Transaction.

The initial implementation enforces this fence in one shared ACID write transaction across Accounts and Journal. A future compare-and-swap or reservation protocol may replace that implementation only if it preserves identical all-or-nothing semantics. Applicable Controls coordination is intentionally deferred to the Controls redesign.
