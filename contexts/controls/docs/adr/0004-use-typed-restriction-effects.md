---
status: superseded by ADR-0009
---

# Use Typed Restriction Effects

Every Restriction has exactly one structured effect: Block Operation or Reserve Amount. A comment may explain that a Restriction represents a legal hold, but free text never controls enforcement and Legal Hold is not a separate entity; this preserves one Restriction model without introducing an arbitrary policy-expression language.
