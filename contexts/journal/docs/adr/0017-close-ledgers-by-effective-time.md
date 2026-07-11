# Close Ledgers by Effective Time

Each Ledger has an auditable Closed Through boundary that rejects new Posted Transactions whose Effective At is on or before it. Advancing the boundary also requires every Pending or Continuation Transaction in the period to be Resolved, Voided, or replaced into an open period, preventing later resolution from restating closed history.
