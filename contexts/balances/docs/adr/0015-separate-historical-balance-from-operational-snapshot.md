# Separate Historical Balance from Operational Snapshot

Point-in-Time Balance reports only Posted Balance using Effective At and at most one knowledge cutoff, Known At or Known Through, while Balance Snapshot reports current recorded operational state including pending totals, Decrease Capacity, and Increase Capacity. Pending commitments and directional capacities are not assigned an economic Effective At, preventing historical accounting queries from mixing incompatible time semantics.
