# Accounts

The Accounts context owns accounting Account identities, immutable denomination and orientation, balance-bound policy, and lifecycle. Transactions, Postings, authoritative acceptance, and derived balance views remain outside this context.

## Language

**Asset**:
A denomination in which quantities are recorded, such as a fiat currency, token, security, or reward unit. Standard fiat Assets and Organization-defined Assets have fixed precision.
_Avoid_: Currency when referring to all asset types, unit

**Account**:
A named record of quantities of exactly one Asset within one Ledger, characterized independently by an Account Role and Normal Side and exposed with a current Account Revision. The Account's Asset, Account Role, and Normal Side do not change.
_Avoid_: Wallet, Product Arrangement, customer account, balance

**Account Revision**:
An opaque Accounts-owned concurrency token identifying one authoritative version of an Account's identity, lifecycle, and policy facts. It advances whenever any authoritative Account fact changes. Journal may record and fence against it, but clients do not construct or increment it.
_Avoid_: Ledger Position, balance version, client counter

**Account Lifecycle**:
The existence state of an Account from its creation in Pending, through staged opening and operation, to permanent closure. Temporary prohibitions on Account use or transition are Controls and do not become Account States.
_Avoid_: Account suspension, Arrangement Freeze

**Account State**:
The lifecycle phase of an Account: Pending, Opening, Open, Closing, or terminal Closed. Pending precedes opening work, Opening performs that work while rejecting ordinary Transactions, Open admits ordinary activity, and Closing drains accepted work before Closed.
_Avoid_: Control, temporary suspension

**Account Opening Gate**:
The conditions required to move an Opening Account to Open: required opening work is complete and no Active applicable Control prohibits the Opening-to-Open transition. Passing the gate permits an explicit transition; it never opens the Account automatically.
_Avoid_: Compliance Account State, implicit activation

**Account Closure Gate**:
The conditions required to move a Closing Account to Closed: its authoritative posted position is exactly zero, no Pending or Continuation Transactions remain, every targeting Control is Ended by its own authority, and no current Ledger Account Assignment references the Account. Closure never ends a Control or removes an Assignment implicitly.
_Avoid_: Forced closure, balance deletion

**Successor Account**:
A later Account linked to a Closed predecessor for navigation and audit continuity. It follows the normal Pending-to-Open lifecycle and neither reopens the predecessor nor migrates its historical activity.
_Avoid_: Reopened Account, renamed Account

**Account Role**:
The immutable relationship an Account has to the Organization's product: Customer or Internal. It is descriptive: it identifies neither a Customer nor a Stakeholder relationship and determines neither the Account's Normal Side nor which Accounts may participate in the same Transaction.
_Avoid_: Normal Side, ownership, Stakeholder

**Normal Side**:
The immutable Posting side that increases an Account's natural balance: Debit or Credit. Both sides may affect the Account; Normal Side is neither a Posting restriction nor a Product type and remains independent of Account Role.
_Avoid_: Account Classification, positive side, Debit Account, Credit Account

**Balance Floor**:
The lowest natural-sign position an Account may reach through balance-consuming Transactions. A floor of zero prevents overdraft, a negative floor enables credit, and an Account without a floor is unconstrained.
_Avoid_: Account Role, Control

**Balance Ceiling**:
The highest natural-sign position an Account may reach through exposure-increasing Transactions. A positive ceiling can limit debit-normal loan or card receivable exposure, and an Account without a ceiling has no upper bound.
_Avoid_: Account Role, Control

**Balance Interval**:
The permitted natural-sign range formed by an Account's optional Balance Floor and Balance Ceiling. Either bound may be absent, but when both exist the Floor cannot exceed the Ceiling.
_Avoid_: Balance, Control range

**Balance Ceiling Change**:
An audited change to an Account's Balance Ceiling that takes effect at its immutable Ledger Position in the Account operation order. Its service-assigned Recorded At cannot be backdated or future-dated, and tightening never rewrites existing exposure or invalidates an accepted Pending Transaction.
_Avoid_: Balance correction, retroactive exposure limit

**Balance Floor Change**:
An audited change to an Account's Balance Floor that takes effect at its immutable Ledger Position in the Account operation order. Its service-assigned Recorded At cannot be backdated or future-dated, and tightening never rewrites existing exposure or invalidates an accepted Pending Transaction.
_Avoid_: Balance correction, retroactive credit limit
