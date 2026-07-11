---
status: superseded by ADR-0013
---

# Separate Availability from Operation Permission

Available Balance reports the unencumbered amount on an Account, while Block Operation Restrictions independently determine whether that amount may be used. An Account Freeze can therefore deny debits while Available Balance remains positive, preventing access controls from masquerading as balance changes.
