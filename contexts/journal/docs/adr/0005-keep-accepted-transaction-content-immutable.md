# Keep Accepted Transaction Content Immutable

Once a Pending or Posted Transaction is accepted, its Accounts, Assets, amounts, and Postings cannot be edited. Pending content changes use a linear Replacement Chain: each successor references one Voided Pending predecessor, and each predecessor has at most one direct Replacement. Separate business work may share a Source Reference but cannot branch that chain. Posted errors use append-only Correction Chains whose Reversal and Adjustment Transactions may themselves be corrected.
