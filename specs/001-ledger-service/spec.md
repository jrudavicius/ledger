# Feature Specification: Ledger Service

**Feature Branch**: N/A - no branch hook configured

**Created**: 2026-07-11

**Status**: Draft

**Input**: User description: "Build a Ledger service with auditable application actions, committed domain state changes, and accountable command tasks"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Record Balanced Ledger Activity (Priority: P1)

An authorized Service Actor, Organization Operator, or Platform Operator can submit typed Command Tasks to create Ledger Accounts and record balanced financial Transactions so product activity is captured reliably.

**Why this priority**: A ledger has no business value until it can accept valid account activity and reject invalid activity without corrupting balances.

**Independent Test**: Create one Debit-normal and one Credit-normal Ledger Account in `Pending`, move each through `Opening` to `Open`, submit a balanced Transaction between them, and verify it is recorded once, each natural-sign balance changes correctly, and an unbalanced Transaction is rejected without balance changes.

**Acceptance Scenarios**:

1. **Given** valid immutable Account creation facts, **When** an authorized actor submits `CreateAccount`, **Then** the system creates the Account in `Pending`; `BeginAccountOpening` moves it to `Opening`, and `CompleteAccountOpening` moves it to `Open` only when the Account Opening Gate passes.
2. **Given** one Debit-normal and one Credit-normal Open Ledger Account denominated in the same Asset, **When** an authorized actor submits equal Debit and Credit Postings to them, **Then** the system records an immutable Transaction, increases both natural-sign Posted Balances correctly, and links the successful action to the committed Transaction state change.
3. **Given** a Transaction whose Debit and Credit Postings do not balance, **When** an authorized actor submits it, **Then** the system rejects the Transaction with a clear reason, records the rejected action, and creates neither Account balance changes nor State Change Records.
4. **Given** a previously accepted Transaction command, **When** the same Idempotency Key and canonical command content are submitted again, **Then** the system returns the original recorded outcome, records the replayed action, and creates neither a duplicate Transaction nor a duplicate State Change Record.

---

### User Story 2 - View Balances And Activity (Priority: P2)

An authorized Operator or Service Actor can retrieve current and historical account balances and inspect the ledger activity that produced those balances.

**Why this priority**: Product teams, finance users, and customer-facing workflows need trustworthy balances and activity history to make decisions.

**Independent Test**: Record several transactions for an account, request current and as-of balances, and verify the returned balances match the accepted ledger activity for the requested dates.

**Acceptance Scenarios**:

1. **Given** an account with accepted ledger entries, **When** an authorized actor requests the current balance, **Then** the system returns the latest balance with account, currency, and timestamp context and records the successful read action without recording a state change.
2. **Given** an account with activity before and after a selected business date, **When** an authorized actor requests the balance as of that date, **Then** the system returns the balance using only activity effective at or before that date.
3. **Given** a date range and account filter, **When** an authorized actor requests ledger activity, **Then** the system returns matching entries with enough detail to reconcile each balance movement.

---

### User Story 3 - Trace And Correct Ledger Records (Priority: P3)

An auditor or finance operator can follow the Audit Trail from an attempted action to any resulting committed state changes, trace balances to source transactions, and correct mistakes without editing or deleting accepted ledger entries.

**Why this priority**: Ledger records must remain trustworthy over time, including when mistakes are discovered after posting.

**Independent Test**: Submit one accepted transaction, one rejected transaction, one balance read, and one correction; verify every action is visible, only committed mutations have State Change Records, and the corrected balance remains explainable from immutable ledger activity.

**Acceptance Scenarios**:

1. **Given** an accepted ledger entry, **When** an authorized auditor reviews its Audit Trail, **Then** the system shows the initiating actor, Organization and Ledger scope, action and correlation identifiers, timestamps, source reference, outcome, committed State Change Record, and authoritative Transaction and Postings.
2. **Given** a rejected transaction submission, **When** an authorized auditor reviews its Audit Trail, **Then** the system shows the attempted action, stable rejection outcome and reason, and confirms that no State Change Record was produced.
3. **Given** an accepted ledger entry that must be corrected, **When** an authorized actor records a reversal or adjustment, **Then** the system preserves the original entry and records the correction as separate ledger activity with its own linked action and state change.
4. **Given** an actor, target, action, command, outcome, correlation identifier, or time range, **When** an authorized auditor searches the Audit Trail, **Then** the system returns the matching causal history in a comprehensible order.
5. **Given** a reconciliation period, **When** an authorized actor requests a reconciliation summary, **Then** the system shows total debits, credits, and net movement by account and currency for that period.

---

### User Story 4 - Submit Accountable Command Tasks (Priority: P4)

An authorized Service Actor, Organization Operator, or Platform Operator can submit the same typed semantic command through one organization-wide Command Task ingress, follow any required approval, and see whether the Task was rejected, executed, or otherwise concluded.

**Why this priority**: Machine and human mutation paths must have one set of domain semantics, idempotency, concurrency, approval, and audit rules without weakening the immutability of financial records.

**Independent Test**: Submit the same semantic command as a Service Actor under immediate policy and as an Operator under approval-required policy; verify both return `202 Accepted` with a durable Command Task status location, the server selects the execution policy, approval causes the original immutable intent to execute without resubmission, and neither command is executed twice.

**Acceptance Scenarios**:

1. **Given** any authorized Actor submitting a typed state-changing command with applicable expected revisions and justification, **When** the service admits it through `POST /v1/organizations/{organizationId}/command-tasks`, **Then** the system creates one durable Command Task with a stable identifier, records the submission Action, and returns `202 Accepted` with `Location` and `Retry-After`.
2. **Given** an authorized Service Actor and a command eligible for immediate execution, **When** the Actor submits it, **Then** server policy selects immediate handling, the POST still returns only an asynchronous receipt, and the Actor polls the Task resource for its terminal outcome.
3. **Given** a Command Task requiring approval, **When** an eligible Operator submits an approval decision, **Then** the system records the decision, keeps requester, approver, and executor distinguishable, and executes the original immutable command when its approval requirements are satisfied.
4. **Given** an unauthorized, invalid, expired, cancelled, or stale Command Task, **When** execution is considered, **Then** the system records a stable outcome and reason without changing the target domain state.
5. **Given** an Idempotency Key already bound to a Command Task, **When** the canonical command is submitted again, **Then** the system returns the original logical receipt and creates no duplicate Task or domain state change; different content with that key is rejected.
6. **Given** a Platform Operator acting for an Organization, **When** the Operator submits, approves, rejects, or cancels a Command Task, **Then** the Audit Trail preserves both the authenticated Platform Operator and the represented Organization rather than presenting the action as Organization-originated.
7. **Given** a client polls a nonterminal Command Task, **When** execution or approval is still outstanding, **Then** the Task response may include `Retry-After`; once terminal, it reports `Succeeded`, `Rejected`, `Cancelled`, `Expired`, or `Failed` and supplies the applicable result or problem link.

---

### User Story 5 - Establish And Administer Controls (Priority: P5)

An authorized Actor can establish, adjust, or end an auditable Control that constrains a named decision without editing its original terms, changing target state by itself, or exposing generic Control CRUD.

**Why this priority**: Customer requests, legal mandates, activity limits, and compliance findings require different enforcement behavior while sharing authority, source-reference, lifecycle, history, and commit-time decision rules.

**Independent Test**: Establish one Control of each typed constraint, exercise the matching target decision, adjust or end the Control under its source authority, and verify immutable history, authoritative enforcement, and idempotent outcomes.

**Acceptance Scenarios**:

1. **Given** an eligible Customer request and authorized support actor, **When** `EstablishControl` targets the Customer's Product Arrangement with `ProhibitAction` for outward movement, **Then** matching outgoing decisions are denied while the Control is Active without changing Account lifecycle or balance.
2. **Given** a legal order naming an amount, **When** `EstablishControl` targets an Account with `ReserveAmount`, **Then** the amount encumbers Decrease Capacity in the Account Asset without changing Posted Balance.
3. **Given** daily and monthly activity policies, **When** independent `UsageLimit` Controls target the same action, **Then** each uses its explicit calendar window, time zone, measure, and Usage Basis, and accepting an action consumes every applicable limit atomically.
4. **Given** an Account in `Opening` and an Active compliance Control prohibiting `Account.OpeningToOpen`, **When** `CompleteAccountOpening` executes, **Then** the Task is rejected and the Account remains `Opening`.
5. **Given** an existing Control, **When** an authorized actor submits `AdjustControl` or `EndControl` under authority appropriate to its source, **Then** the system appends a Control Change and never patches, deletes, or overwrites the original Control terms.

### Edge Cases

- Transactions with postings that do not balance are rejected before any balance changes occur.
- Transactions referencing missing Accounts or Accounts outside `Open` are rejected with an actionable reason unless the activity is explicitly authorized opening, closure, or correction work.
- Duplicate Command Task submissions using the same Idempotency Key and canonical content create no more than one accepted domain outcome; a Source Reference remains reusable business correlation.
- Corrections never mutate or delete accepted entries; they are represented as reversal or adjustment entries.
- A successful read or rejected action produces an Action Record but no State Change Record.
- An action that commits changes to several subjects links every State Change Record through one causal action and one atomic change set.
- A retry after Task admission or a committed domain change returns the original Task receipt and status location, records the retry, and never repeats the Task or domain change.
- A background process that changes domain state does so as a Service Actor even though no external request or Operator initiated it directly.
- Authentication failures preserve the attempted action and available request context without inventing an actor identity.
- Audit evidence excludes credentials, secrets, and unapproved sensitive payload values while retaining enough context to investigate the action.
- A state-changing outcome is not reported as successful unless its Action Record and resulting State Change Records are durably preserved.
- A Command Task whose expected subject revision is stale at execution is rejected without overwriting intervening changes; submission or approval does not lock domain state.
- Cancellation, expiry, or approval rejection prevents a Command Task from executing unless a new Command Task is submitted.
- Every admitted command POST returns `202 Accepted` with a status `Location` and `Retry-After`; even an immediately eligible command exposes its terminal outcome only through the polled Command Task resource.
- Ending an Account Opening Block removes the denial but never opens the Account automatically; a new `CompleteAccountOpening` command is required.
- Concurrent limited actions cannot both consume the same remaining Usage Limit, and idempotent replay never consumes usage twice.
- Transactions that mix currencies are rejected unless every posting currency is explicitly allowed for the participating accounts.
- Concurrent submissions affecting the same account produce balances that reflect each accepted transaction exactly once.
- Historical balance queries include only entries effective at or before the requested business date.
- Reconciliation periods with no activity return zero totals and clear empty-state information.
- A query made immediately after a successful mutation either reflects at least that committed change or clearly reports that its view has not reached the mutation's returned consistency position; it never presents an undetectably stale result as current.
- Rebuilding any derived balance, activity, reconciliation, command-status, or Audit Trail view from authoritative immutable history produces the same result for the same point in that history and creates no new domain state changes.
- A Transaction racing an Account lifecycle change or applicable Control decision is accepted only when the invariants were valid at the committed revision; stale derived views cannot authorize the Transaction.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow authorized Actors to create Ledger Accounts with a name, Account Role, Normal Side (`Debit` or `Credit`), Asset, optional Balance Floor and Balance Ceiling, and unique identifier. A new Account MUST start in `Pending`, and its Account Role, Normal Side, and Asset MUST NOT change.
- **FR-002**: The system MUST support the Account State progression `Pending` to `Opening` to `Open` to `Closing` to terminal `Closed`. `Opening` to `Open` MUST require the Account Opening Gate, and `Closing` to `Closed` MUST require the Account Closure Gate.
- **FR-003**: The system MUST reject new ordinary activity on `Pending`, `Opening`, `Closing`, or `Closed` Accounts while allowing only explicitly authorized opening, closure, commitment-completion, or correction activity under the canonical Account State rules.
- **FR-004**: The system MUST validate that every ledger transaction contains at least two postings before it can be accepted.
- **FR-005**: The system MUST validate that total debit postings equal total credit postings for each transaction before it can be accepted.
- **FR-006**: The system MUST reject transactions that reference missing accounts, unauthorized actors, invalid amounts, unsupported currencies, or unbalanced postings.
- **FR-007**: The system MUST record accepted transactions as immutable ledger entries with a unique identifier, business date, recorded timestamp, source reference, description, initiator, and postings.
- **FR-008**: The system MUST use the Organization-and-calling-client Idempotency Key namespace to prevent duplicate accepted Transactions. Source Reference MUST correlate related business activity and MUST NOT serve as retry identity.
- **FR-009**: The system MUST expose each Account's latest Posted Balance from Postings in Posted Transactions, calculated as debits minus credits for a Debit-normal Account and credits minus debits for a Credit-normal Account.
- **FR-010**: The system MUST expose balances as of a requested business date using accepted ledger entries effective at or before that date.
- **FR-011**: The system MUST expose ledger activity filtered by account, date range, transaction identifier, source reference, amount, status, and currency.
- **FR-012**: The system MUST preserve an append-only Audit Trail for externally initiated actions, system execution attempts, operator decisions, and committed domain state changes, including accepted and rejected transaction submissions and access to balances and activity.
- **FR-013**: The system MUST support corrections through separate reversal or adjustment entries rather than edits or deletions to accepted entries.
- **FR-014**: The system MUST provide reconciliation summaries showing total debits, total credits, and net movement by account, currency, and period.
- **FR-015**: The system MUST enforce authorization for every typed Command Task submission, approval decision, rejection, cancellation, and system execution, and for Account, Transaction, Control, balance, activity, reconciliation, and Audit Trail queries.
- **FR-016**: The system MUST return stable outcome categories and human-readable messages for successful acceptance or execution, pending approval, validation failure, authorization failure, rejection, replayed submission, cancellation, expiry, execution failure, and temporary unavailability.
- **FR-017**: The system MUST retain accepted ledger entries and related audit information for the retention period required by the product's financial record policy.
- **FR-018**: The system MUST create exactly one Action Record for every attempted externally visible operation and every system execution attempt, including successful reads, rejected requests, authentication or authorization failures, and idempotent replays.
- **FR-019**: Each Action Record MUST identify the action, origin, actor when known, authenticated identity, represented Organization when applicable, target references, request identifier when available, correlation identifier, start and completion times, sanitized input summary or fingerprint, stable outcome, and reason when the outcome is not successful.
- **FR-020**: The system MUST create a State Change Record for every successfully committed domain subject transition, identifying the subject context, type, and identifier; semantic transition; previous and resulting revision; selected audit-safe before-and-after values; effective and recorded times; causing Action Record; and atomic change set.
- **FR-021**: Each State Change Record MUST have exactly one causing Action Record, while one Action Record MAY cause zero or more State Change Records; all state changes committed together MUST be identifiable as one change set.
- **FR-022**: Reads, rejected actions, failed actions, authorization failures, and replayed requests that return an existing result MUST create no new State Change Records. Derived Balance Snapshots and balance components MUST NOT be represented as independent state changes.
- **FR-023**: Action Records and State Change Records MUST NOT be edited or deleted. A correction to audit metadata MUST be represented by an additional linked record that preserves the original evidence.
- **FR-024**: Audit evidence MUST exclude credentials, secrets, and payload values not explicitly approved for audit retention while preserving enough sanitized context to identify and investigate the action.
- **FR-025**: Authorized auditors MUST be able to search the Audit Trail by Organization, Ledger, Actor, authenticated principal, Action, target, Command Task, outcome, reason, request or correlation identifier, and time range, and follow the causal links to authoritative domain records.
- **FR-026**: Every admitted state-changing command from a Service Actor, Organization Operator, or Platform Operator MUST create one durable Command Task containing a stable identifier, typed semantic command, targets, applicable expected revisions, sanitized parameters, requester, represented Organization, justification, request time, requested effective time when applicable, execution policy, and idempotency identity.
- **FR-027**: A Command Task MUST preserve every receipt, approval, rejection, cancellation, expiry, execution, success, and failure transition that led to its current or terminal outcome, together with the applicable result or problem links.
- **FR-028**: The server MUST select immediate or approval-required execution policy from authenticated Actor, command, target, and organizational policy. A caller MUST NOT select immediate handling. When approval is required, the system MUST prevent execution before approval, enforce approver eligibility and requester separation, and record each decision as an attributable Action Record.
- **FR-029**: The Audit Trail MUST distinguish Organization Operators from Platform Operators. When a Platform Operator acts for an Organization, it MUST preserve both the authenticated principal and the represented Organization without attributing the action to an Organization Operator.
- **FR-030**: Every command MUST express typed semantic domain intent, such as completing Account opening, establishing a Control, or recording an adjustment, and MUST NOT provide generic object CRUD, JSON Patch, arbitrary scripts, or edit/delete operations for accepted Transactions, Postings, Controls, or audit history.
- **FR-031**: Repeated submission of the same Idempotency Key and canonical command MUST return the original logical receipt and outcome without duplicating a Command Task or domain state change. A command whose expected subject revision is stale when execution occurs MUST be rejected without overwriting intervening changes.
- **FR-032**: The system MUST ensure that a reported successful mutation has its authoritative domain change history, Action Record, and all resulting State Change Records durably preserved as one atomic outcome, and MUST prevent a persistence failure from producing an untraceable or ambiguously successful domain change.
- **FR-033**: A scheduled or otherwise automated process that attempts an application action MUST do so as a Service Actor and follow the same Action Record and State Change Record rules as externally initiated actions.
- **FR-034**: Every admitted Task receipt MUST return an opaque consistency position for admission, every terminal `Succeeded` Task MUST expose the domain commit's consistency position, and every derived query result MUST identify the position through which it is current. A caller MUST be able to require a query result at least as current as a supplied position or receive a clear not-yet-current outcome rather than an undetectably stale result.
- **FR-035**: The system MUST be able to rebuild all derived balances, activity views, reconciliation summaries, Command Task views, Control views, and searchable Audit Trail views from authoritative immutable history without changing their observable results at the same history position.
- **FR-036**: A state-changing decision MUST evaluate business invariants against authoritative state that remains valid through commit. The initial implementation MUST use one ACID write transaction across Accounts and Journal to record and fence the evaluated Account Revision for every affected Account, append the complete Journal Commit at one Ledger Position, and preserve the idempotency and audit outcome atomically; any mismatch invalidates the entire Transaction decision for re-evaluation. Eventually consistent query views MUST NOT authorize Transaction acceptance, enforce expected revisions or idempotency, or decide Account lifecycle and applicable Control invariants.
- **FR-037**: The only externally visible mutation endpoint MUST be `POST /v1/organizations/{organizationId}/command-tasks`. Accounts, Transactions, Controls, Command Tasks, balances, reconciliation, and Audit Trail MAY expose typed `GET` queries, but the API MUST expose no direct resource mutation route and no public execution-attempt route.
- **FR-038**: Every admitted command POST MUST return `202 Accepted`, a `Location` for its Command Task, and `Retry-After`. The POST MUST NOT return an inline terminal result, including for immediate-policy Service Actor commands. A nonterminal Task GET MAY return `Retry-After`; terminal `Succeeded`, `Rejected`, `Cancelled`, `Expired`, or `Failed` Tasks MUST expose the applicable result or problem links.
- **FR-039**: Account lifecycle mutation commands MUST include `CreateAccount`, `BeginAccountOpening`, `CompleteAccountOpening`, `BeginAccountClosing`, and `CompleteAccountClosure`; they MUST enforce only the corresponding canonical transition and gate.
- **FR-040**: Control mutation commands MUST include `EstablishControl`, `AdjustControl`, and `EndControl`. Every Control MUST have exactly one Product Arrangement, Account, or Payment Device target and exactly one typed `ProhibitAction`, `ReserveAmount`, or `UsageLimit` constraint.
- **FR-041**: A Control's identity, target, original terms, source authority, source reference, and constraint type MUST remain immutable. Adjustment and ending MUST append attributable Control Changes under authority appropriate to the source; no command may implicitly change target lifecycle state.
- **FR-042**: Execution MUST evaluate expected revisions, Account gates, every Active applicable Control, and authoritative Limit Usage against state that remains valid through commit. Admitting or approving a Task MUST neither reserve capacity nor guarantee later success.
- **FR-043**: Accepting an action governed by one or more Usage Limits and consuming every applicable limit MUST succeed or fail atomically. Limit windows MUST use explicit boundary rules and time zones, and idempotent replay MUST NOT consume usage again.

### User Experience Requirements *(mandatory for user-facing features)*

- **UX-001**: Ledger outcomes MUST be understandable to finance users, operators, and client-system owners without requiring knowledge of implementation details.
- **UX-002**: The feature MUST define clear empty, success, validation failure, authorization failure, duplicate, and temporary-unavailable states for each affected flow.
- **UX-003**: Error messages MUST identify the affected account, transaction, field, or source reference when that information is available and the actor is authorized to see it.
- **UX-004**: Balance and activity views MUST display currency, business date, recorded timestamp, and entry status wherever those values affect interpretation.
- **UX-005**: Any direct user-facing surfaces built for this feature MUST follow existing navigation, copy, interaction, and accessibility expectations for the product.
- **UX-006**: Audit views MUST present Action Records, Command Tasks, State Change Records, and authoritative domain records as a causal timeline that distinguishes attempted actions from committed changes.
- **UX-007**: Command Task views MUST clearly distinguish receipt, pending approval, approval, execution, success, rejection, failure, cancellation, and expiry so a `202 Accepted` receipt is never mistaken for a completed domain change.
- **UX-008**: Audit and command views MUST redact protected values consistently and indicate when information is intentionally omitted rather than absent.

### Performance Requirements *(mandatory)*

- **PR-001**: Standard Transaction command submissions MUST return a durable `202 Accepted` receipt and status location within 1 second for at least 95% of admitted attempts under expected launch volume.
- **PR-002**: Single-account current and historical balance lookups MUST complete within 2 seconds for at least 95% of attempts for accounts with up to 100,000 ledger entries.
- **PR-003**: Reconciliation summaries for one calendar month and up to 100,000 matching ledger entries MUST complete within 30 seconds or provide a clear deferred result state.
- **PR-004**: When performance limits are reached, the system MUST avoid partial or ambiguous acceptance and MUST provide a clear outcome that can be retried or investigated.
- **PR-005**: At least 95% of Audit Trail searches over up to 100,000 matching records MUST return an initial result within 5 seconds, with larger result sets offering a clear deferred or incremental result state.
- **PR-006**: At least 95% of admitted Command Task submissions MUST return a durable `202 Accepted` receipt with status location within 2 seconds under expected launch volume.

### Key Entities *(include if feature involves data)*

- **Ledger**: An independent accounting book owned by one Organization and used as a boundary for Accounts, Transactions, and one authoritative Journal History ordered by Ledger Position.
- **Ledger Account**: A named record of quantities of exactly one immutable Asset, with an immutable Normal Side, Account Role, Account State, and balances derived from Postings.
- **Normal Side**: The immutable Posting side, Debit or Credit, that increases an Account's natural-sign balance; it is not a product type or a restriction on the other Posting side.
- **Ledger Transaction**: A business event submitted for recording in the ledger, identified by a source reference and business date.
- **Posting**: One debit or credit line within a ledger transaction that affects exactly one account and amount.
- **Ledger Entry**: The immutable accepted record of a ledger transaction and its postings.
- **Balance**: The calculated position of an account at the latest point or at a requested business date.
- **Correction Entry**: A reversal or adjustment entry that explains and corrects prior ledger activity without changing the original entry.
- **Actor**: A known identity accountable for attempting an application action. Every Actor is either an Operator or a Service Actor; an attempted action may have no identified Actor when authentication fails.
- **Operator**: A human Actor.
- **Service Actor**: A non-human Actor representing an authenticated service identity, including another service or an internal scheduled or background service.
- **Organization Operator**: An Operator authorized by an Organization to request or decide operational changes within that Organization's scope.
- **Platform Operator**: An Operator belonging to the platform who may act for an Organization while retaining a distinct platform identity in the Audit Trail.
- **Command Task**: A durable, uniquely identified typed semantic command submitted by a Service Actor or Operator, including expected revisions, justification, server-selected execution policy, approvals when required, lifecycle, and final outcome.
- **Control**: An auditable, independently enforceable constraint with one target, one typed constraint, authority, source reference, effective period, state, and immutable history.
- **Control Change**: An attributable append-only adjustment or ending of one Control under authority appropriate to its source.
- **Limit Usage**: The authoritative recognized consumption of one Usage Limit in one explicit window, consumed atomically with acceptance of the controlled action.
- **Audit Trail**: The append-only, causally linked history of Action Records and State Change Records used to explain attempted actions and committed domain changes.
- **Action Record**: Immutable evidence that an Actor or unidentified caller attempted a named application action, including context, timing, sanitized input evidence, outcome, and reason; it exists even when no state changes.
- **State Change Record**: Immutable audit evidence, deterministically derivable from authoritative domain history, that an action committed a semantic transition to one domain subject, including its revisions, selected audit-safe before-and-after values, and causal link. It is not a second source of domain state.
- **Change Set**: The group of State Change Records committed together as one indivisible result of an action.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of accepted ledger transactions in acceptance testing have balanced debit and credit totals.
- **SC-002**: 0 unbalanced, unauthorized, or duplicate transactions create account balance changes in acceptance testing.
- **SC-003**: An authorized actor can create accounts, record a valid transaction, and view the updated balances in under 3 minutes during an end-to-end workflow test.
- **SC-004**: At least 95% of admitted standard Transaction command submissions return a durable `202 Accepted` receipt and status location within 1 second under expected launch volume.
- **SC-005**: At least 95% of account balance lookups return current or historical balances within 2 seconds for accounts with up to 100,000 ledger entries.
- **SC-006**: Auditors can trace any displayed account balance through the causing actions, accepted entries, state changes, and corrections in under 5 minutes.
- **SC-007**: Duplicate submissions with the same Idempotency Key and canonical command result in exactly one accepted Transaction and one set of committed State Change Records, while preserving every submission attempt as an Action Record, in 100% of duplicate-submission tests.
- **SC-008**: Reconciliation summaries for a monthly period with up to 100,000 matching entries complete or enter a clear deferred result state within 30 seconds.
- **SC-009**: In acceptance testing, 100% of successful, rejected, unauthorized, failed, and replayed actions produce exactly one Action Record with a stable outcome and no credentials or unapproved sensitive values.
- **SC-010**: In acceptance testing, 100% of committed domain subject transitions have a causally linked State Change Record, while reads and actions that commit no change produce zero State Change Records.
- **SC-011**: In 100% of Command Task tests, auditors can identify the requester, represented Organization, justification, server-selected execution policy, required approval decisions, executor, final outcome, and resulting domain changes from one causal history.
- **SC-012**: Repeating the same Idempotency Key and canonical command any number of times produces no more than one Command Task, one logical execution, and one resulting domain change set in 100% of idempotency tests.
- **SC-013**: At least 95% of Audit Trail searches over up to 100,000 matching records return an initial result within 5 seconds under expected launch volume.
- **SC-014**: In acceptance testing, rebuilding every derived view from the beginning of authoritative history produces results identical to the pre-rebuild views at the same history position in 100% of tested cases.
- **SC-015**: In acceptance testing, 100% of queries made with a successful mutation's consistency position either include that mutation or return a clear not-yet-current outcome; none silently return an older view as current.
- **SC-016**: In concurrency testing, 100% of races between Transaction acceptance and relevant Account lifecycle or Control changes produce an outcome consistent with one valid committed ordering, without accepting a Transaction against stale authorization state.
- **SC-017**: In acceptance testing, 100% of admitted mutation submissions return `202 Accepted` with `Location` and `Retry-After`, and no POST returns an inline terminal command result.
- **SC-018**: In acceptance testing, 100% of Accounts are created in `Pending`, reach `Open` only through `BeginAccountOpening` and `CompleteAccountOpening`, and remain `Opening` when an Active Control prohibits the opening transition.
- **SC-019**: In concurrency testing, 100% of controlled-action races either consume every applicable Usage Limit with the accepted action or consume none, and retries consume no additional usage.

## Assumptions

- Product-specific offerings and rules, including Everyday, Multi-currency, and Credit offerings, remain outside the Ledger service. Product workflows express their accounting effects through Ledger primitives; Ledger stores neither a Product type nor a Product Arrangement identifier on an Account.
- A Multi-currency Product Arrangement coordinates multiple single-Asset Ledger Accounts rather than making one Ledger Account multi-Asset.

- "Ledger service" means a double-entry financial ledger for product and accounting activity, not a cryptocurrency ledger, blockchain wallet, bank core, or general append-only event log.
- The first version serves authorized Service Actors, finance users, operators, and auditors; it does not include a standalone consumer-facing ledger application.
- Accepted ledger entries are immutable. Mistakes are handled through reversal or adjustment entries.
- A Transaction may contain several Assets only when its debit and credit Postings balance independently for each Asset. Exchange-rate selection, market valuation, foreign-exchange revaluation, tax reporting, and payment settlement remain outside the Ledger service.
- Authentication and actor identity are available from the surrounding product environment.
- The product has or will define a financial record retention policy; until then, accepted ledger entries and audit records are treated as long-lived records that are not automatically purged.
- "State change" means a committed transition of a domain subject instance. Database schema changes, domain-model definition changes, deployments, and migrations belong to a separate engineering change trail and are outside this specification.
- Each Ledger's authoritative Journal History preserves complete Journal Commits, accepted Transactions, and Postings as immutable facts and is sufficient to reconstruct financial state. Per-Account histories, indexes, balances, and snapshots are derived rather than duplicate authorities. The Audit Trail explains cause and access history but is not itself authoritative financial history, and Action Records for reads or unsuccessful attempts never participate in financial state reconstruction.
- Balance Snapshots and their components remain derived from accepted Transaction and Posting facts in authoritative history and therefore do not create independent State Change Records.
- Every state-changing intent from a Service Actor or Operator is represented by a durable Command Task submitted through the one organization-wide mutation endpoint.
- Approval requirements and requester-approver separation are selected by server policy; the first version does not require dual approval for every command.
- Commands use typed semantic domain language and expected subject revisions rather than unrestricted object editing.
- Command submission uses Asynchronous Request-Reply. A `202 Accepted` response confirms durable admission only; clients follow `Location` and respect `Retry-After` until the Command Task is terminal.
- Audit views retain only explicitly approved request and change values; sensitive inputs are represented through redaction, sanitized summaries, or fingerprints.
- Automated processing uses Service Actor identities supplied by the surrounding product environment.
