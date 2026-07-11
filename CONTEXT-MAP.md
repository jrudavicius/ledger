# Context Map

## Shared Language

- [Shared Language](./SHARED-LANGUAGE.md) defines Organization, operation ordering and identity, and architectural accounting terms used across bounded contexts. It is not a bounded context.

## Contexts

- [Accounts](./contexts/accounts/CONTEXT.md) - owns Account identity, immutable accounting properties, bounds policy, opening, and closure lifecycle
- [Journal](./contexts/journal/CONTEXT.md) - owns Ledgers, their authoritative Journal Histories, and balanced Transaction recording, correction, resolution, and acceptance
- [Balances](./contexts/balances/CONTEXT.md) - owns rebuildable current and historical balance and directional-capacity queries
- [Products](./contexts/products/CONTEXT.md) - defines versioned financial offerings and their opened Product Arrangements
- [Customers](./contexts/customers/CONTEXT.md) - represents an Organization's Customers and their Stakeholder relationships to Product Arrangements
- [Payment Instruments](./contexts/payment-instruments/CONTEXT.md) - identifies payment-facing devices and associates them with Product Arrangements
- [Controls](./contexts/controls/CONTEXT.md) - owns auditable Controls on Product Arrangements, Accounts, and Payment Devices

## Relationships

- **Products -> Accounts**: Product Definitions prescribe Account requirements, and Product Arrangements assign concrete Accounts to them; Accounts remains unaware of product semantics.
- **Customers -> Products**: Customers relates Customers to Product Arrangements through Stakeholder roles; Products does not own Customer identity or Stakeholder semantics.
- **Payment Instruments -> Products**: A Payment Device Link references one Product Arrangement; Product rules resolve accepted activity to a concrete Ledger Account Assignment.
- **Controls -> Products**: Controls evaluates Controls targeting Product Arrangements; Products enforces blocked Product Capabilities before producing Journal activity.
- **Controls -> Accounts**: Controls targets Accounts and may prohibit lifecycle transitions; Accounts owns Account state and transitions.
- **Journal -> Accounts**: Journal imports each affected Account's Asset, Normal Side, lifecycle, bound policy, and Account Revision; Journal Commit records and fences the evaluated revisions before authoritative Transaction acceptance.
- **Journal -> Controls**: Journal imports applicable permission, usage, and Reserve Amount decisions in the same authoritative ordering as Transaction acceptance.
- **Balances -> Journal**: Balances projects accepted Transaction, Posting, time, state, and Ledger Position facts.
- **Balances -> Accounts**: Balances imports Account Asset, Normal Side, and bounds to interpret Journal facts.
- **Balances -> Controls**: Balances imports applicable Reserve Amount effects for Decrease Capacity.
- **Accounts -> Journal**: Every Account references one Journal-owned Ledger; Account closure also requires authoritative Journal evidence that the Account has zero posted position and no Pending or Continuation commitment.
- **Accounts -> Products**: Account closure requires evidence that no current Ledger Account Assignment references the Account.
- **Accounts -> Controls**: Account opening requires authoritative applicable Control state, while closure requires every targeting Control to be Ended by its own authority; Accounts never creates or ends those Controls implicitly.
- **Controls -> Customers**: Controls may reference the Customer who requested an Arrangement Freeze; Customers owns Customer identity.
- **Controls -> Payment Instruments**: Controls evaluates Controls targeting Payment Devices; Payment Instruments enforces denial before affected device operations.
