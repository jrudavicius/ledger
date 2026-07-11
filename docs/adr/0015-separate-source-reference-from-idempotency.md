# Separate Source Reference from Idempotency

Source Reference correlates all Ledger activity produced by one upstream business activity, while Idempotency Key identifies exactly one requested operation. Related Pending, resolution, continuation, and correction operations may share a Source Reference but require distinct Idempotency Keys, preventing business grouping from incorrectly suppressing legitimate writes.
