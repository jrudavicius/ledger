# Keep the Ledger Domain-Neutral

> Boundary note: [[docs/adr/0014-split-ledger-into-accounting-contexts|ADR 0014]] replaced the former Ledger bounded context with Accounts, Journal, and Balances; references to the Ledger context below describe the earlier boundary.

The Ledger context will model generic accounting concepts such as ledgers, accounts, transactions, and postings rather than product-specific concepts such as wallets, loans, or settlements. This lets different Organizations map their own products into the ledger, accepting that product-specific workflows and semantics must remain outside the Ledger rather than being supplied as built-in behavior.
