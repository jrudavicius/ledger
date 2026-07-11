# Use Balance Floors for Credit Capacity

Each constrained Account has an explicit Balance Floor that is not inferred from Account Role: zero prevents overdraft and a negative value enables a credit product. Posted Balance may fall below zero down to that floor, while Decrease Capacity reports remaining room above it after decreasing Pending Transaction Net Account Effects and Reserve Amount effects are deducted; Decrease Capacity is not applicable to an Account without a floor.
