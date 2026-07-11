# Require a Fresh Check for Overcapture

A Pending Transaction derives separate decrease and increase Resolution Limits for each affected Account and Asset from its Net Account Effect. Reservation Consumption uses each linked Posted or Continuation Transaction's Net Account Effect and aggregates effects gross by direction across Transactions. Consumption cannot exceed either directional limit; any excess is a separate Transaction subject to current Restrictions and a fresh Availability Check, preventing settlement from silently expanding an earlier reservation.
