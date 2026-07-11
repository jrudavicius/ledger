# Balances

The Balances context owns rebuildable current and historical query views derived from Journal facts, Account policy, and applicable Control effects. It owns no accounting mutation and never authorizes Transaction acceptance or Account closure.

## Language

**Known At**:
The optional Recorded At cutoff used to reproduce the information available at a past instant. It includes every fact recorded at or before that instant and applies those facts in Ledger Position order. It is mutually exclusive with Known Through; omitting both means current knowledge.
_Avoid_: Known Through, Effective At, request time

**Known Through**:
The optional Ledger Position cutoff used to reproduce an exact committed prefix of one Ledger. It includes facts at or before that position and is mutually exclusive with Known At; omitting both means current knowledge.
_Avoid_: Known At, Consistency Position, pagination cursor

**Balance Snapshot**:
A view of one Account's current recorded operational state: Posted Balance, Pending Debits, Pending Credits, Decrease Capacity, and Increase Capacity. Its components are derived rather than maintained as independent balance buckets.
_Avoid_: Balance bucket, committed balance

**Point-in-Time Balance**:
A historical Posted Balance constrained by an Effective At cutoff and at most one knowledge cutoff: Known At for a wall-clock view or Known Through for an exact Ledger Position prefix. Omitting both uses current knowledge. Included facts are applied in Ledger Position order, and the result excludes pending totals and directional capacities.
_Avoid_: As-of balance without time dimension

**Posted Balance**:
A natural-sign Account position derived only from Postings in Posted Transactions. It is debits minus credits for a Debit-normal Account and credits minus debits for a Credit-normal Account; a negative value is a contrary balance.
_Avoid_: Committed Balance

**Pending Debits**:
The gross total of debit Postings for an Account in pending activity. It is a reporting component of a Balance Snapshot, not a separate balance and not the direct input to directional capacity.
_Avoid_: Pending outgoing balance

**Pending Credits**:
The gross total of credit Postings for an Account in pending activity. It is a reporting component of a Balance Snapshot, not a separate balance and not the direct input to directional capacity.
_Avoid_: Pending incoming balance

**Decrease Capacity**:
For an Account with a Balance Floor, the non-negative room remaining for natural-sign decreases after the floor, the aggregate magnitudes of decreasing Net Account Effects from Pending Transactions, and applicable Reserve Amount effects are deducted from Posted Balance. Increasing effects from distinct Pending Transactions do not offset them or release capacity until Posted; it is not applicable when the Account has no Balance Floor.
_Avoid_: Available Balance, permission, spend authorization

**Increase Capacity**:
For an Account with a Balance Ceiling, the non-negative room remaining for natural-sign increases after Posted Balance and the aggregate magnitudes of increasing Net Account Effects from Pending Transactions are deducted from the ceiling. Decreasing effects from distinct Pending Transactions do not offset them or release capacity until Posted; it is not applicable when the Account has no Balance Ceiling.
_Avoid_: Available Credit, permission, receive authorization
