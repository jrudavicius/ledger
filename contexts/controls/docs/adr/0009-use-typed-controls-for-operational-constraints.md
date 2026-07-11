# Use Typed Controls for Operational Constraints

The Controls context uses one identified, auditable Control model instead of a Restriction entity. Every Control targets exactly one Product Arrangement, Ledger Account, or Payment Device and carries exactly one constraint from the closed Prohibit Action, Reserve Amount, or Usage Limit union; a named Account lifecycle transition is a Controlled Action, so Compliance can block Opening-to-Open without Controls owning Account State.

This keeps source-specific lifecycle and immutable history consistent across prohibitions, legal amount holds, limits, and transition gates while avoiding a generic policy-expression language. It supersedes ADR-0004, preserves the prospective and independently releasable behavior of existing Controls decisions, and requires target decisions and limit consumption to share an authoritative order.
