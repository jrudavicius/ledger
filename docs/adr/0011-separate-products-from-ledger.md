# Separate Products from Ledger

> Boundary note: [[docs/adr/0014-split-ledger-into-accounting-contexts|ADR 0014]] replaced the former Ledger bounded context with Accounts, Journal, and Balances; references to the Ledger context below describe the earlier boundary.

The service has distinct Products and Ledger contexts. Products owns immutable, version-addressed Product Definitions, opened Product Arrangements, product capabilities, terms, and Ledger Account requirements, while Ledger stores domain-neutral Accounts with an immutable Normal Side and enforces accounting invariants; a Product Definition may prescribe Account creation values but cannot dynamically reinterpret an existing Account or its history. Financial-statement classifications, if required, belong to a separate chart-of-accounts or reporting model rather than being inferred from a Product.
