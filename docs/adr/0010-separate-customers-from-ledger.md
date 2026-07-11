---
status: superseded by ADR-0012
---

# Separate Customers from Ledger

> Boundary note: [[docs/adr/0014-split-ledger-into-accounting-contexts|ADR 0014]] replaced the former Ledger bounded context with Accounts, Journal, and Balances; references to the Ledger context below describe the earlier boundary.

The service has distinct Customers and Ledger contexts. Customers owns Customer identity and the many-to-many relationships in which Customers are Stakeholders of Ledger Accounts, while Ledger stores no Customer identity references or Stakeholder relationships; this preserves the domain-neutral accounting model at the cost of cross-context lookup and coordination when Stakeholder relationships change.
