---
status: superseded by ADR-0012
---

# Model Temporary Account Blocks as Controls

Temporary prohibitions such as a Customer-Requested Account Freeze are independent Restrictions while the Account remains active; they do not change Account Lifecycle. This prevents temporary operational blocks and permanent closure from sharing state, and allows a support Freeze to remain in force when an unrelated amount-reserving Restriction ends.
