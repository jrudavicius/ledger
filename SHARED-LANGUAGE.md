# Shared Language

These terms span the accounting bounded contexts and have one system-wide meaning. They live here to avoid making Accounts, Journal, or Balances the accidental owner of cross-context identity and ordering policy.

## Language

**Organization**:
A fintech using the platform that owns one or more independent Ledgers.
_Avoid_: Tenant, client, Customer

**Recorded At**:
The immutable service-assigned wall-clock instant when an operation was accepted into authoritative evaluation. It cannot be backdated or future-dated by the Organization, may repeat across committed mutations, and never determines replay, concurrency, or audit order.
_Avoid_: Ledger Position, Effective At, client timestamp

**Ledger Position**:
The immutable service-assigned commit coordinate that totally orders Journal Commits within one Ledger's Journal History. It determines Ledger-local replay and audit order, need not be consecutive or exposed as a number, and may be encoded inside a broader opaque Consistency Position.
_Avoid_: Recorded At, Effective At, row identifier

**Consistency Position**:
An opaque client-visible coordinate identifying a point in globally committed history for projection freshness. Successful mutations return it, derived queries report how far they have advanced, and callers may require a minimum position. It may encode a Ledger Position but is neither a Ledger-local business identifier nor a timestamp.
_Avoid_: Ledger Position, pagination cursor, Recorded At

**Source Reference**:
An Organization-provided business identifier that correlates related accounting operations to upstream activity. Several operations may share it, so it is not retry identity.
_Avoid_: Idempotency Key, Transaction ID

**Idempotency Key**:
An Organization-provided identity for exactly one requested operation within an Idempotency Namespace. Reuse with the same content returns the original outcome, while reuse with different content is a conflict.
_Avoid_: Source Reference, business identifier

**Idempotency Namespace**:
The single keyspace shared by every mutating accounting operation and Ledger for one Organization and calling client integration.
_Avoid_: Endpoint keyspace, per-context keyspace, per-Ledger keyspace

**Key-Consuming Outcome**:
An accepted result or stable business rejection reached after a valid, authorized operation enters authoritative evaluation. Malformed requests, authentication or authorization failures, and temporary unavailability do not consume an Idempotency Key.
_Avoid_: Retryable failure, transport error

**Consumed Key Binding**:
The non-reusable association between an Idempotency Key, its operation content, and its authoritative outcome within one Idempotency Namespace. It is retained for at least the applicable financial-record retention period.
_Avoid_: Expired key, reusable key

**Ledger Primitive**:
A domain-neutral accounting concept used to represent the monetary effects of a financial product. Ledgers, Accounts, Transactions, and Postings are Ledger Primitives even though their definitions belong to different bounded contexts.
_Avoid_: Product object, fintech object

## Related Decisions

- [[docs/adr/0014-split-ledger-into-accounting-contexts|Split Ledger into Accounting Contexts]]
- [[docs/adr/0015-separate-source-reference-from-idempotency|Separate Source Reference from Idempotency]]
- [[docs/adr/0016-use-one-idempotency-namespace-per-client|Use One Idempotency Namespace per Client]]
- [[docs/adr/0017-persist-stable-idempotent-outcomes|Persist Stable Idempotent Outcomes]]
- [[docs/adr/0018-never-reuse-consumed-idempotency-keys|Never Reuse Consumed Idempotency Keys]]
- [[docs/adr/0019-separate-ledger-position-from-recorded-time|Separate Ledger Position from Recorded Time]]
