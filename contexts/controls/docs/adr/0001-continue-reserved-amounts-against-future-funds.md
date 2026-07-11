---
status: superseded by ADR-0007
---

# Continue Reserved Amounts Against Future Funds

A Reserve Amount effect retains its full outstanding amount even when that amount exceeds the target Account's current Posted Balance. Available funds are floored at zero and later credits remain encumbered until the Restriction is adjusted or ends, preserving the required amount rather than silently limiting it to a point-in-time balance.
