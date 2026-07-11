# Journal

The Journal context owns independent accounting books and the authoritative recording, lifecycle, correction, and acceptance of balanced Transactions and their Postings. Account identity and policy belong to Accounts, while derived balance queries belong to Balances.

## Language

**Ledger**:
An independent accounting book owned by one Organization and scoped by that Organization to a legal entity, product, environment, or another accounting boundary. It owns one Journal History; Accounts and Transactions belong to exactly one Ledger, and a Transaction cannot post across Ledgers.
_Avoid_: Organization, tenant, bounded context

**Journal History**:
The authoritative Ledger-partitioned append-only sequence of Journal Commits ordered by Ledger Position. A Transaction's immutable content is introduced exactly once, while later commits may append its lifecycle and relationship facts without rewriting it. Per-Account activity streams, indexes, balances, and write snapshots are derived.
_Avoid_: Account stream, balance store, physical shard

**Transaction**:
An indivisible record of monetary activity within one Ledger, composed of at least two strictly positive Postings whose debits and credits balance independently for every Asset involved. At least one Account must have a non-zero Net Account Effect. A Journal Commit accepts the complete Transaction as part of one change set at an immutable Ledger Position, after which its Accounts, Assets, amounts, and Postings remain immutable.
_Avoid_: Payment, transfer

**Journal Commit**:
The successful atomic append of one complete Journal change set at one Ledger Position after an Account Revision Fence succeeds. A change set may accept complete Transactions with all their Posting facts and may transition already accepted Transactions through explicit links. Direct acceptance includes one new Transaction; Transaction Resolution includes its original's transition, at least one complete Posted settlement Transaction, and at most one complete Continuation Transaction. A failure appends none of the change set. Journal Commit defines the domain atomicity boundary without requiring one physical stream, table, or storage partition per Ledger.
_Avoid_: Independent Posting append, per-Transaction subcommit, partial change set, physical stream

**Account Revision Fence**:
The Journal Commit condition that every affected Account's current Account Revision still equals the revision whose lifecycle, Asset, Normal Side, and bounds Journal evaluated. Any mismatch invalidates the entire decision for re-evaluation; no Transaction, Posting, link, or lifecycle transition partially appends.
_Avoid_: Client expected revision, stale Account snapshot, partial retry

**Effective At**:
The immutable Organization-provided instant when Posted activity economically belongs for reporting. For Posted Transactions it may equal or precede Recorded At but never follow it, and it never changes Ledger Position, acceptance-time controls, or what the service knew earlier.
_Avoid_: Ledger Position, Recorded At, creation time

**Closed Through**:
The latest Effective At instant in a Ledger that is closed to new Posted activity. Posting on or before it is rejected, and moving the boundary backward requires an explicit authorized reopening with an audit trail.
_Avoid_: Recorded At cutoff, retention boundary

**Period Close Gate**:
The conditions required to advance Closed Through: no Pending or Continuation Transaction has Effective At on or before the proposed boundary. Each such commitment must first be Resolved, Voided, or replaced into an open period.
_Avoid_: Account Closure Gate, forced period close

**Transaction State**:
The lifecycle position of a balanced Transaction: Pending, Posted, Resolved, or Voided. Direct final activity is Posted; a Pending Transaction becomes Resolved through linked Posted Transactions or Voided when nothing is posted, and neither terminal state contributes to pending totals.
_Avoid_: Validation state, processing result

**Correction Transaction**:
A new Posted Transaction linked to prior Posted activity that corrects its accounting effect without changing either record.
_Avoid_: Edited Transaction, deleted Posting

**Reversal Transaction**:
A Correction Transaction that exactly negates every Posting of one original Posted Transaction.
_Avoid_: Adjustment Transaction, deletion

**Adjustment Transaction**:
A Correction Transaction that records a balanced delta when exact reversal is not appropriate.
_Avoid_: Reversal Transaction, edited amount

**Correction Chain**:
An original Posted Transaction and the ordered Reversal or Adjustment Transactions that directly or indirectly correct it. Its net accounting effect is derived from the complete chain rather than a mutable reversed flag.
_Avoid_: Reversed flag, overwritten Transaction

**Closed Account Correction**:
An explicitly authorized Correction Transaction that may reference a Closed Account only when the complete atomic correction leaves that Account at exactly zero with no pending commitment. Any resulting position is transferred to an Open successor or adjustment Account.
_Avoid_: Reopened Account, non-zero Closed Account

**Replacement Transaction**:
A new Transaction explicitly linked to one Voided Pending Transaction whose accounting content needed to change. A Voided Pending Transaction has at most one direct Replacement; changing that successor requires voiding and replacing the successor. The original remains unchanged and auditable.
_Avoid_: Edited Transaction, updated Posting

**Replacement Chain**:
A non-branching sequence of Pending Transactions connected by direct Replacement links. Each successor references its immediate Voided predecessor; separate business work may share a Source Reference but does not branch the chain.
_Avoid_: Replacement tree, Source Reference group

**Transaction Resolution**:
The atomic conclusion of a Pending Transaction in one Journal Commit by creating at least one linked Posted settlement Transaction and either releasing the remainder or carrying it into a Continuation Transaction. The original becomes Resolved and every new Transaction is accepted complete at the same Ledger Position; its accounting content remains unchanged. If nothing settles, the original remains Pending, is Voided, or is Voided and linked to a Replacement Transaction; a zero-settlement operation is not a Transaction Resolution.
_Avoid_: Edited Pending Transaction, partial Posting

**Continuation Transaction**:
A new Pending Transaction created atomically by a Transaction Resolution to carry an unsettled remainder after at least one linked Posted settlement Transaction is created. It has its own identity, links to the Resolved original, and preserves immutable Transaction content across repeated partial settlements.
_Avoid_: Remaining balance field, edited Pending Transaction

**Resolution Limit**:
The maximum natural-sign movement in one direction that a Transaction Resolution may consume for an Account and Asset from its Pending Transaction. Each affected Account derives separate decrease and increase Resolution Limits from that Pending Transaction's Net Account Effect; only the effect's direction has a non-zero limit. Linked Posted and Continuation Transactions cannot exceed either limit; excess in either direction requires a separate Transaction and fresh Availability Check.
_Avoid_: Overcapture, implicit credit

**Reservation Consumption**:
The directional Net Account Effect of a linked Posted or Continuation Transaction claimed from a Pending Transaction by a Transaction Resolution. Decrease and increase consumption are declared separately, and effects from distinct Transactions do not offset. A resolution's balancing Postings may use different Accounts, but any movement not covered by Reservation Consumption requires a fresh Availability Check.
_Avoid_: Proportional Posting copy, unrestricted settlement

**Posting**:
One debit or credit line in a Transaction against exactly one Account and therefore exactly one Asset. Its amount is strictly positive and its Debit or Credit side carries direction. A Posting is accepted only through its Transaction's Journal Commit and has no independent append, source, destination, lifecycle, or command surface.
_Avoid_: Signed amount, zero Posting, Transaction, ledger entry

**Net Account Effect**:
The single natural-sign change derived for one Account by summing every Posting against it within one Transaction. Positive is an increase, negative is a decrease, and zero consumes no directional capacity. An individual Account effect may be zero in an otherwise non-zero Transaction; effects from distinct Transactions never offset.
_Avoid_: Net Posting, cross-Transaction netting, mutable balance

**No Economic Effect**:
A stable business rejection returned when valid positive Postings produce a zero Net Account Effect for every Account in a proposed Transaction. No Transaction or Posting is accepted, and the outcome consumes the operation's Idempotency Key under the Key-Consuming Outcome rule. A zero or negative Posting amount is malformed input and never reaches this decision.
_Avoid_: Audit-only Transaction, accepted no-op

**Over-Ceiling**:
The condition in which an Account's authoritative position is above its current Balance Ceiling or accepted commitments consume more increasing room than the ceiling permits. Increase Capacity is zero and new increases are rejected while accepted commitments may resolve and decreases restore compliance.
_Avoid_: Closed Account, rewritten exposure

**Over-Floor**:
The condition in which an Account's authoritative position is below its current Balance Floor or accepted commitments consume more decreasing room than the floor permits. Decrease Capacity is zero and new decreases are rejected while accepted commitments may resolve and increases restore compliance.
_Avoid_: Closed Account, rewritten debt

**Availability Check**:
The atomic decision that evaluates a proposed Transaction's Net Account Effects against every affected Account's configured Balance Floor and Balance Ceiling after existing Pending Transaction effects are aggregated gross by direction and Reserve Amount effects are considered. Effects from distinct Transactions do not offset, and the Transaction reserves capacity on all affected Accounts or none.
_Avoid_: Balance pre-check, partial reservation
