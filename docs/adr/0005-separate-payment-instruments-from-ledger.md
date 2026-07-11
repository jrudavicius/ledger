---
status: superseded by ADR-0012
---

# Separate Payment Instruments from Ledger

The service includes distinct Ledger and Payment Instruments contexts. Payment Instruments owns Payment Devices and Payment Device Links that reference Ledger Accounts, while Ledger remains unaware of payment-specific semantics; this supports payment-facing identifiers without coupling the reusable accounting model to cards, IBANs, or other payment instruments.
