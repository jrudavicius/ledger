# Use One Idempotency Namespace per Client

Each Organization and calling client integration shares one Idempotency Key namespace across all mutating operations and Ledgers. A key reused anywhere in that namespace returns its original outcome or conflicts when the content differs, preventing endpoint or Ledger boundaries from allowing accidental duplicate financial activity.
