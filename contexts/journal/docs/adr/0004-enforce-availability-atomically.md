# Enforce Availability Atomically

Transaction acceptance evaluates the proposed Transaction's Net Account Effects against Balance Floors, Balance Ceilings, existing Pending Transaction effects aggregated gross by direction, and Reserve Amount Restrictions in the same atomic decision that reserves or posts every affected Account. Concurrent requests cannot consume the same capacity, and a multi-Account Transaction succeeds everywhere or has no effect.
