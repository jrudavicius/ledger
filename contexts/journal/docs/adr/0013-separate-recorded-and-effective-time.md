# Separate Recorded and Effective Time

Every accepted Transaction has immutable Ledger Position, Recorded At, and Effective At values. Ledger Position establishes Ledger-local replay and audit order; Recorded At is the service-assigned wall-clock instant when the activity was accepted and may repeat; Effective At places Posted activity in economic history. Backdated effective activity may restate historical reporting but cannot alter Ledger Position or bypass the Controls and capacity evaluated at acceptance.
