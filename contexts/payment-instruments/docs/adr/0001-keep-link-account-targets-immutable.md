---
status: superseded by ADR-0002
---

# Keep Link Account Targets Immutable

A Payment Device Link permanently targets the Account selected when the Link is created. Reassignment requires deactivating the old Link and creating a new one, ensuring delayed or retried payments cannot resolve to a different Account and preserving an auditable history of both the Link used and the Account affected.
