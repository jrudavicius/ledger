# Order Restriction Changes with Target Operations

Restriction lifecycle changes and affected operation acceptances have one deterministic order per target. If acceptance occurs first it remains valid; if Restriction activation occurs first the matching operation is denied, eliminating races where both Controls and the target context claim precedence.
