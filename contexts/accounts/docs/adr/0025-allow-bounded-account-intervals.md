# Allow Bounded Account Intervals

An Account may have an optional Balance Floor, an optional Balance Ceiling, both, or neither. Together these optional bounds define its Balance Interval; when both exist the Floor cannot exceed the Ceiling, and Journal atomically enforces the complete interval during Transaction acceptance.
