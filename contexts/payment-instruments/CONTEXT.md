# Payment Instruments

The Payment Instruments context represents the identifiers used to initiate or direct payments and associates them with Product Arrangements in the Products context.

## Language

**Payment Device**:
An instrument or address used to initiate or direct a payment, such as a card or IBAN. Its identity is the Organization, Device Scheme, Identifier Namespace, and normalized identifier value, none of which may change.
_Avoid_: Product Arrangement, Ledger Account, Account Alias

**Device Scheme**:
The kind of Payment Device identifier and its validation and normalization rules, such as IBAN, Card Token, or Tag.
_Avoid_: Identifier Namespace, payment product

**Identifier Namespace**:
The authority or domain within which a normalized Payment Device value is unique, such as global IBANs, a payment provider's tokens, or Organization-local tags.
_Avoid_: Device Scheme, Ledger

**Payment Device State**:
The lifecycle phase of a Payment Device: Active or terminal Retired. Retirement prospectively deactivates its Active Link and prevents new activity without blocking already accepted Pending Transactions from resolving; temporary prohibitions are Controls instead.
_Avoid_: Control, deleted Device

**Payment Device Link**:
A first-class association with its own stable identifier that connects one Payment Device to one immutable target Product Arrangement. A Payment Device has at most one Active Link but may retain many historical Links; each Link may be deactivated but never retargeted.
_Avoid_: Account Alias, Account Link

**Payment Device Link State**:
Whether a Payment Device Link is Active and may resolve new activity or Inactive and retained only for history. Inactive is terminal; reconnecting requires a new Link identity.
_Avoid_: Deleted Link, Product Arrangement lifecycle

**Accepted Account Resolution**:
The immutable Ledger Account selected for an accepted operation by applying the rules of the target Product Arrangement's bound Product Definition to its Ledger Account Assignments. The operation owner retains this result, and delayed handling or retries reuse it rather than resolving the operation again.
_Avoid_: Retry-time resolution, Payment Device Link target
