# Resolve Pending with Linked Posted Transactions

A Pending Transaction concludes as Resolved only by atomically creating at least one linked Posted settlement Transaction and either releasing any remainder or carrying it into a new Pending Continuation Transaction. A Continuation therefore proves non-zero settlement progress. If nothing settles, the original remains Pending, is Voided, or is Voided and linked to a Replacement Transaction; zero settlement is not a Transaction Resolution. Original accounting content remains immutable while repeated partial settlements form an auditable chain.
