# Candidate Command Task REST API

[`openapi.json`](./openapi.json) is the design-time contract for one
organization-wide mutation ingress plus typed resource queries. It turns the
feature requirements and accepted domain decisions into a reviewable OpenAPI
catalogue; it is not evidence that the API is implemented.

The only mutation endpoint is:

```text
POST /v1/organizations/{organizationId}/command-tasks
```

Accounts and Ledger queries remain nested below their Ledger. Command Task and
Control queries are Organization-scoped because their targets and workflows may
cross Ledger, Product Arrangement, and Payment Device boundaries. Organization,
Ledger, Asset, identity, and authorization administration remain outside this
contract. IDs, revisions, cursors, and consistency positions are opaque.

## Selected Command Task design

Every Service Actor, Organization Operator, and Platform Operator submits a
typed semantic command through the same collection. The closed command union
includes:

- Account commands: `CreateAccount`, `BeginAccountOpening`,
  `CompleteAccountOpening`, `BeginAccountClosing`, and
  `CompleteAccountClosure`;
- Control commands: `EstablishControl`, `AdjustControl`, and `EndControl`;
- typed Transaction, correction, and Account-bound commands already required by
  the Ledger model;
- Task decisions such as `DecideCommandTaskApproval` and
  `CancelCommandTask`.

The endpoint is generic; command content is not. Each union member has a closed
schema and semantic invariants. There is no arbitrary command payload, generic
CRUD, JSON Patch, resource deletion, direct mutation route, or public execution
attempt route.

The server selects `Immediate` or `ApprovalRequired` policy from the
authenticated Actor, represented Organization, command, and target. Callers
cannot request immediate handling. Approval records an attributable decision
against the original immutable Task; once eligible, the service executes that
intent automatically rather than requiring the client to submit it again.

Every admitted POST uses Asynchronous Request-Reply:

1. The service durably admits the Command Task and returns `202 Accepted`.
2. `Location` identifies
   `/v1/organizations/{organizationId}/command-tasks/{commandTaskId}`.
3. `Retry-After` advises when to poll.
4. A nonterminal Task GET may return another `Retry-After`.
5. Only the Task resource reports terminal `Succeeded`, `Rejected`,
   `Cancelled`, `Expired`, or `Failed`, with the applicable result or
   problem links.

This rule also applies to an immediately eligible Service Actor command. A
`202` receipt means durable admission, never successful domain execution.

Every externally visible attempt creates one Action Record. A successful
domain mutation also atomically commits authoritative domain history,
idempotency outcome, and State Change Records. Reads, rejected or failed
attempts, and idempotent replays create no new domain State Change Records.

## Actor ingress rules

| Actor | Mutation ingress | Execution handling | Query ingress |
|---|---|---|---|
| Service Actor, including background processing | `POST .../command-tasks` | Usually immediate when policy permits; always acknowledged asynchronously | Authorized typed GETs |
| Organization Operator | `POST .../command-tasks` | Immediate or approval-required according to server policy | Authorized typed GETs |
| Platform Operator acting for an Organization | Same Command Task ingress | Same policy; audit retains platform identity and represented Organization | Authorized typed GETs |

Bearer authentication supplies the principal and calling-client integration.
Bodies never accept `actorId`, `requesterId`, a claimed Actor kind, or an
execution-policy override. Authentication failures are audited with available
request context without inventing an Actor.

## Request catalogue

| Capability | Request |
|---|---|
| Submit any typed mutation, approval, rejection, or cancellation | `POST /v1/organizations/{organizationId}/command-tasks` |
| Poll one Command Task and read its revision, transitions, decisions, and terminal links | `GET /v1/organizations/{organizationId}/command-tasks/{commandTaskId}` |
| Search Command Tasks | `GET /v1/organizations/{organizationId}/command-tasks` |
| Read an Account and its revision | `GET /v1/organizations/{organizationId}/ledgers/{ledgerId}/accounts/{accountId}` |
| Read current Balance Snapshot | `GET .../accounts/{accountId}/balance-snapshot` |
| Read bitemporal Posted-only Point-in-Time Balance | `GET .../accounts/{accountId}/point-in-time-balance` |
| Search or read immutable Transactions | `GET .../transactions`, `GET .../transactions/{transactionId}` |
| Summarize reconciliation by Account and Asset | `GET .../reconciliation-summaries` |
| Read or search Controls | `GET /v1/organizations/{organizationId}/controls/{controlId}`, `GET /v1/organizations/{organizationId}/controls` |
| Read immutable Control History | `GET /v1/organizations/{organizationId}/controls/{controlId}/history` |
| Read Usage Limit consumption | `GET /v1/organizations/{organizationId}/controls/{controlId}/usage` |
| Search Action Records and follow causal timeline | Typed Audit Trail GETs |

`ChangeBalanceFloor` and `ChangeBalanceCeiling` remain typed commands. Both
take effect prospectively at execution `recordedAt` and cannot be backdated
or future-dated.

## Protocol conventions

### Headers, identity, and exact amounts

- Send `Authorization: Bearer ...` on every request.
- Send `Idempotency-Key` on every `POST`. The key is scoped to one Organization
  and calling client integration across every command type and Ledger.
- `X-Correlation-Id` is optional and relates calls in one business flow; it is
  not retry identity.
- Every admitted POST returns `202 Accepted`, `Location`, `Retry-After`,
  `X-Action-Id`, and `X-Consistency-Position`.
- Every successful query returns `X-Action-Id`.
- Every successful query also returns `X-Current-Through-Position`.
- Financial quantities are JSON decimal strings, never floating-point numbers.
  Their permitted scale comes from the Account's immutable Asset.

Account Role, Asset, and Normal Side are immutable. `CreateAccount` creates an
Account in `Pending`; `BeginAccountOpening` moves it to `Opening`, and
`CompleteAccountOpening` attempts `Opening` to `Open` against the
authoritative Account Opening Gate. `BeginAccountClosing` and
`CompleteAccountClosure` perform only the corresponding `Open` to `Closing`
and `Closing` to `Closed` transitions. Ending an opening-blocking Control
never opens the Account automatically.

A changed economic purpose uses a Successor Account plus explicit transfer
Transactions. Balance Floor and Ceiling changes are prospective at execution
`recordedAt`; they cannot be backdated or future-dated. Tightening preserves
existing exposure and accepted commitments.

`EstablishControl` creates exactly one target and one typed
`ProhibitAction`, `ReserveAmount`, or `UsageLimit` constraint.
`AdjustControl` and `EndControl` append attributable history under the
Control's source authority; they never patch or delete original terms. A
matching controlled action and every applicable Usage Limit consumption commit
atomically.

`recordedAt` is server-assigned when accepted activity is durably observed.
`effectiveAt` is Organization-supplied business time and may be backdated when
policy allows. Backdating changes effective-time reporting; it never causes
acceptance to use historical Account or Control state or bypass the invariants
enforced against authoritative state at commit.

The two balance queries intentionally answer different questions.
`balance-snapshot` returns current recorded operational state, including Posted
Balance, pending totals, Reserve Amount effects, and Available Balance.
`point-in-time-balance` returns Posted Balance only, at a required `effectiveAt`
cutoff and an optional `knownAt` cutoff that defaults to current knowledge.
Pending commitments and availability never appear in historical reporting.

Reversals and adjustments always create separate balanced Transactions. A
correction may mention a `Closed` Account only when the complete atomic
operation leaves that Account at exactly zero and creates no Pending
commitment; any real corrected position belongs on an `Open` successor or
adjustment Account.

The authenticated principal, represented Organization, request fingerprint,
and sanitized input are captured by the service for audit. Credentials and
unapproved sensitive values are never copied into audit evidence.

### Idempotency

An Idempotency Key identifies one Command Task submission; `sourceReference`
correlates related business activity and is not a retry key. Reusing a key with
the same canonical command returns the original Task receipt and status
location without another Task or domain change. Reusing it with different
content returns `IDEMPOTENCY_KEY_REUSED`.

Durable Task admission consumes the key. Malformed requests, authentication or
authorization failures, and temporary unavailability before admission do not.
A consumed key remains bound to its original content and Task for at least the
financial-record retention period and cannot later identify new work. Each
retry is still a distinct attempted Action and receives its own audit evidence.

An expected-revision or business-rule rejection reached during Task execution
is terminal on that Task and remains stable even if domain state later changes.
`IDEMPOTENCY_KEY_REUSED` creates no new binding, projection lag is a query
conflict, and pre-admission temporary failures remain retryable with the same
key. Problem bodies expose `idempotencyKeyConsumed` when applicable.

### Read-after-write consistency

Write models are authoritative; query views are rebuildable and may lag. Treat
`X-Consistency-Position` as an opaque token. A subsequent `GET` may pass it as
`minimumConsistencyPosition`. The query either returns a view current through
at least that position and reports `X-Current-Through-Position`, or returns a
`PROJECTION_NOT_CURRENT` HTTP 409 problem with its current-through position and
`Retry-After`. It must not silently present an older view as current.

### Filtering and pagination

Collection queries use operation-specific filters plus cursor pagination:

- `pageSize` limits the page;
- `pageAfter` is the opaque cursor returned by the previous page;
- `nextPageAfter` is absent when no later page exists.

Clients must not parse cursors and should keep the same filters while following
one result set. Search results use deterministic ordering defined by each
operation, with a unique identifier as the tie-breaker.

### Problems

All non-success application responses use `application/problem+json`. The HTTP
status describes the broad transport outcome; the stable `code` is the client
decision key. Problems include `actionId` when an attempted action was recorded,
`correlationId`, and may include field violations, `currentRevision`,
`currentThroughPosition`, or `retryAfter` when relevant.

Important codes include `TRANSACTION_UNBALANCED_BY_ASSET`, `STALE_REVISION`,
`IDEMPOTENCY_KEY_REUSED`, `PROJECTION_NOT_CURRENT`,
`REQUESTER_CANNOT_APPROVE`, and `TEMPORARILY_UNAVAILABLE`. Clients should display
the human-readable `detail` but branch only on `status` and `code`.

## Examples

The following examples use placeholder IDs and tokens. Request bodies are
validated by the exact schemas in `openapi.json`.

Submit a Transaction command as a Service Actor:

```http
POST /v1/organizations/org_123/command-tasks HTTP/1.1
Authorization: Bearer <service-token>
Content-Type: application/json
Idempotency-Key: 01J2TXN7M5R8N3E0Q4Y6W9K2AB
X-Correlation-Id: checkout_8472

{
  "type": "RecordTransaction",
  "target": { "type": "Ledger", "id": "ledger_main" },
  "expectedRevision": "42",
  "justification": "Capture order 8472",
  "parameters": {
    "initialState": "Posted",
    "effectiveAt": "2026-07-10T12:00:00Z",
    "sourceReference": "order_8472",
    "description": "Capture order 8472",
    "postings": [
      { "accountId": "acct_cash", "side": "Debit", "amount": "125.00" },
      { "accountId": "acct_revenue", "side": "Credit", "amount": "125.00" }
    ]
  }
}
```

Even when server policy selects immediate execution, the submission returns only
an asynchronous receipt:

```http
HTTP/1.1 202 Accepted
Location: /v1/organizations/org_123/command-tasks/task_8472
Retry-After: 2
X-Action-Id: action_submit_8472
X-Consistency-Position: 000000004281

{
  "commandTaskId": "task_8472",
  "state": "Received",
  "statusUrl": "/v1/organizations/org_123/command-tasks/task_8472"
}
```

Poll the status URL:

```http
GET /v1/organizations/org_123/command-tasks/task_8472 HTTP/1.1
Authorization: Bearer <service-token>
```

A terminal Task reports `Succeeded` and links to its result; a business
rejection reports `Rejected` and links to a stable problem. Nonterminal
responses may repeat `Retry-After`.

Use the terminal Task's consistency position for a non-stale balance read:

```http
GET /v1/organizations/org_123/ledgers/ledger_main/accounts/acct_cash/balance-snapshot?minimumConsistencyPosition=000000004281 HTTP/1.1
Authorization: Bearer <service-token>
X-Correlation-Id: checkout_8472
```

Reproduce the Posted Balance as it was knowable at an earlier time:

```http
GET /v1/organizations/org_123/ledgers/ledger_main/accounts/acct_cash/point-in-time-balance?effectiveAt=2026-06-30T23%3A59%3A59Z&knownAt=2026-07-11T12%3A00%3A00Z HTTP/1.1
Authorization: Bearer <auditor-token>
```

A human Operator uses the same endpoint and command schema. If policy requires
approval, the submitted Task becomes pending approval. An eligible approver
records the decision as another typed Task:

```http
POST /v1/organizations/org_123/command-tasks HTTP/1.1
Authorization: Bearer <approver-token>
Content-Type: application/json
Idempotency-Key: 01J2CMD7M5R8N3E0Q4Y6W9K2AB

{
  "type": "DecideCommandTaskApproval",
  "target": { "type": "CommandTask", "id": "task_requires_approval" },
  "expectedRevision": "3",
  "justification": "Independent review completed",
  "parameters": { "decision": "Approve" }
}
```

Establish a compliance opening block through the same mutation ingress:

```json
{
  "type": "EstablishControl",
  "target": {
    "type": "Account",
    "ledgerId": "ledger_main",
    "id": "acct_pending_review"
  },
  "justification": "Customer evidence requires review",
  "parameters": {
    "constraint": {
      "type": "ProhibitAction",
      "action": "Account.OpeningToOpen"
    },
    "authority": {
      "type": "ComplianceFinding",
      "authorityId": "compliance_lt"
    },
    "sourceReference": {
      "scheme": "compliance-case",
      "value": "KYC-7712"
    }
  }
}
```

While that Control is Active, `CompleteAccountOpening` reaches terminal
`Rejected` and the Account remains `Opening`. Ending the Control does not
open the Account; a new opening command with a new Idempotency Key is required.

## Known specification and domain mismatches

The contract makes provisional choices where the feature text and accepted
domain language disagree. These are review items, not silent resolutions:

- **Asset, Normal Side, and Account Role.** The feature text sometimes says
  `currency` and describes a Ledger Account as tracking currency. The domain
  model supports any fixed-precision **Asset** (fiat, token, security, or reward
  unit), so the contract uses `assetId`. It requires immutable `normalSide`
  (`Debit` or `Credit`) independently from `accountRole` (`Customer` or
  `Internal`). Normal Side determines natural-sign balance arithmetic; it is
  neither a Posting restriction nor a Product offering or accounting-statement
  classification.
- **Pending completion in ADR 0005 versus ADR 0006.** ADR 0005 says a Pending
  Transaction may become Posted or Voided. ADR 0006 preserves it and resolves
  it by atomically creating linked Posted Transactions, optionally creating a
  Pending Continuation; zero settlement becomes Voided. The contract follows
  ADR 0006 through typed resolution, voiding, and replacement commands. ADR 0005
  should be amended or marked superseded so there is one lifecycle definition.
- **Business Date versus Effective At.** The feature uses a date-only
  `businessDate`, while the domain and contract distinguish Organization-supplied
  `effectiveAt` from server-assigned `recordedAt`. Calendar cut-off, time-zone,
  and date-only compatibility semantics still need an explicit decision before
  implementation. A Posted Transaction cannot be future-effective and cannot
  post on or before the Ledger's `closedThrough` boundary.
- **Pending time semantics.** ADR 0015 says Pending commitments have no
  economic Effective At, while ADR 0017 needs to place Pending and Continuation
  Transactions relative to `closedThrough`. The candidate contract uses
  `effectiveAt` provisionally for that period-close placement but excludes
  Pending activity from Point-in-Time Balance. These ADRs should name a
  distinct Pending cutoff if the two meanings are not intended to share a
  field.

## Deliberate exclusions

- Organization, Ledger, Asset catalogue, authentication client, user, and role
  administration. This currently includes requests to advance or reopen a
  Ledger's `closedThrough` boundary; ADR 0017 defines their domain behavior but
  authorization and HTTP ingress remain outside this feature contract.
- Product catalogue, Product Definition, Product Arrangement, product-opening,
  and product-servicing APIs; those belong to the Products context.
- Generic CRUD, JSON Patch, deletion, or in-place mutation of accepted
  Transactions, Postings, Controls, audit evidence, or Command Task history.
- Foreign-exchange rates, valuation, conversion, tax, payment orchestration,
  settlement-network integration, and product-specific wallet/loan semantics.
- Event-store, Domain Event, projection-rebuild, snapshot-storage, and internal
  worker protocols. These are implementation concerns behind the REST contract.
- Consumer-facing UI, bulk import/export, webhooks, and streaming subscriptions.

## Validate the contract

From the repository root, run:

```powershell
node --test specs/001-ledger-service/contracts/openapi.contract.test.mjs
```

The test uses only Node's built-in test runner. It verifies the single mutation
route, asynchronous `202` receipt headers, Task polling, local references,
idempotency and consistency metadata, the closed command union, exact decimal
amounts, absence of direct mutation and edit/delete routes, and critical stable
problem codes.

For a strict OpenAPI 3.1 standards and style check, run the pinned linter
(this command downloads the tool through `npx` when it is not already cached):

```powershell
npx.cmd --yes @redocly/cli@2.36.0 lint --extends=recommended-strict specs/001-ledger-service/contracts/openapi.json
```
