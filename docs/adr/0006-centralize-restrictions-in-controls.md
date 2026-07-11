---
status: superseded by ADR-0012
---

# Centralize Restrictions in Controls

The Controls context owns a single Restriction model that can target either a Ledger Account or a Payment Device and carries a structured Block Operation or Reserve Amount effect. Ledger and Payment Instruments enforce applicable effects without owning separate restriction definitions, avoiding divergent semantics while keeping accounting and payment-instrument concepts in their respective contexts.
