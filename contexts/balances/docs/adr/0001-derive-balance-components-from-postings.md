# Derive Balance Components from Postings

Posted Balance, Pending Debits, and Pending Credits are projections of Postings in their respective transaction states rather than independently mutable balance buckets. This keeps every reported position traceable to ledger activity and prevents cancellation or posting workflows from manually transferring amounts between unrelated counters.
