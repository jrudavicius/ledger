# Support Bitemporal Balance Queries

A Point-in-Time Balance accepts an Effective At cutoff and at most one optional knowledge cutoff: Known At selects a wall-clock view by Recorded At, while Known Through selects an exact committed Ledger Position prefix. The two are mutually exclusive, and omitting both uses current knowledge. Included facts are applied in Ledger Position order, allowing late backdated activity and exact historical reproduction without treating timestamps as commit order.
