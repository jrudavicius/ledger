# Controls

The Controls context owns auditable Controls that constrain named decisions on Product Arrangements, Ledger Accounts, and Payment Devices through a closed set of typed Control Constraints. Target contexts retain ownership of their actions, lifecycles, and accounting facts.

## Language

**Control**:
An independently enforceable constraint with its own identity, Control Rationale, Control Authority, Control Source Reference, effective period, Control State, exactly one Control Target, and exactly one Control Constraint. An Active Control constrains a decision without granting permission, rerouting work, or rewriting an accepted decision.
_Avoid_: Restriction, permission, target status, generic policy rule

**Control Target**:
The one Product Arrangement, Ledger Account, or Payment Device whose decision boundary must enforce a Control. A Customer may be connected to the Control's mandate or history without becoming its target.
_Avoid_: Control Authority, requesting Customer, affected collection

**Control Rationale**:
A free-form explanation of why a Control exists. It never determines enforcement behavior or substitutes for a source reference.
_Avoid_: Control Constraint, Control Authority

**Control Source Reference**:
The authority-scoped business identifier for the request, legal order, compliance finding, product rule, or other mandate that caused a Control. It correlates related Controls but is neither their identity nor a Ledger Transaction Source Reference.
_Avoid_: Control ID, free-text rationale

**Control Constraint**:
The structured behavior enforced by a Control: Prohibit Action, Reserve Amount, or Usage Limit. It is a closed catalogue of typed constraints, not an arbitrary rule expression.
_Avoid_: Free-text rule, script, permission

**Controlled Action**:
A named decision owned by a target context, such as using an outward Product Capability, accepting an Account-decreasing Transaction, using a Payment Device, or transitioning an Account from Opening to Open. Controls names the decision but does not own its meaning or lifecycle.
_Avoid_: API endpoint, untyped operation name

**Prohibit Action**:
A Control Constraint that denies a matching Controlled Action while the Control is Active. It leaves the target's state unchanged when the attempted action is denied.
_Avoid_: Reserve Amount, Usage Limit, permission

**Reserve Amount**:
An Account-only Control Constraint that encumbers a structured amount of Decrease Capacity in the Account's Asset without changing Posted Balance. It may exceed current Decrease Capacity and continues to encumber capacity created by future natural-sign increases until reduced or the Control ends; it does not affect Increase Capacity under a Balance Ceiling.
_Avoid_: Legal Hold as a separate enforcement type, pending debit, free-text amount

**Usage Limit**:
A Control Constraint that caps the measured use of one Controlled Action during each Limit Window under one Usage Basis. It measures either a count or an amount in exactly one Asset and denies a candidate action only when recognized Limit Usage plus the candidate would exceed the limit.
_Avoid_: Balance Floor, Balance Ceiling, generic velocity expression

**Limit Window**:
The explicit half-open recurring interval over which a Usage Limit accumulates usage, assigned by service acceptance time and defined with a boundary rule and time zone. Calendar day and calendar month are supported examples rather than implicit meanings of daily or monthly.
_Avoid_: Rolling period without boundaries, server-local day

**Usage Basis**:
The typed rule for which accepted use remains in Limit Usage: Gross Accepted Usage never decreases after a later void or refund, while Outstanding Usage changes only through an explicit release of unused consumption. Each Usage Limit declares one basis; Ledger balance effects never select it implicitly.
_Avoid_: Inferred refund behavior, mutable accounting balance

**Limit Usage**:
The recognized cumulative count or Asset amount for one Usage Limit in one Limit Window. Accepting a matching action records its usage in the same authoritative decision, and an idempotent retry never consumes the limit twice.
_Avoid_: Posted Balance, derived best-effort counter

**Control Evaluation**:
The decision made when a Controlled Action is first accepted against all Active applicable Controls and authoritative Limit Usage. A Control activated later does not retroactively reinterpret an accepted action or Pending Transaction.
_Avoid_: Retroactive control, posting-time reinterpretation

**Target Decision Order**:
The definitive order among Control lifecycle changes, Control Adjustments, Controlled Action acceptances, and Limit Usage consumption for the same target. An earlier acceptance remains valid, while an earlier Control change governs the later decision.
_Avoid_: Timestamp guess, race window

**Control Adjustment**:
An explicit Control Change that alters an adjustable value, such as a Reserve Amount or Usage Limit threshold, under the same source reference while preserving the Control's original terms. Changing its target or constraint type requires a new Control.
_Avoid_: Edited Control, replacement without history

**Arrangement Freeze**:
A Control targeting one Product Arrangement whose Prohibit Action constraint denies named Product Capabilities, such as customer-initiated outward movement, without changing Arrangement Terms, Assignments, or any assigned Ledger Account's lifecycle or balance.
_Avoid_: Account debit block, Reserve Amount, arrangement closure

**Customer-Requested Arrangement Freeze**:
An Arrangement Freeze requested by a Customer who is a Stakeholder of the target Product Arrangement and applied by an authorized support actor. The requesting Customer and applying actor are both part of its Control History.
_Avoid_: Account suspension, inactive Account, Customer-Requested Account Freeze

**Account Opening Block**:
An Account-targeted Control whose Prohibit Action constraint denies the Opening-to-Open transition. The Account remains Opening until the Control ends and the Account Opening Gate is otherwise satisfied.
_Avoid_: Compliance Account State, rejected Account, implicit closure

**Control Authority**:
The source of mandate for creating, changing, or ending a Control, distinct from the actor performing the action. A Control may be changed or ended only under authority appropriate to its own source.
_Avoid_: Actor, generic administrator

**Control Change**:
An action affecting exactly one Control and recording the performing actor, Control Authority, time, and reason.
_Avoid_: Generic unblock, bulk release

**Control History**:
The immutable original terms of a Control together with its ordered Control Changes. A Control remains in its history after it ends and is never overwritten or deleted.
_Avoid_: Mutable Control record, deleted Control

**Control State**:
The enforcement phase of a Control: Scheduled before its effective start, Active while enforced, or Ended afterward.
_Avoid_: Released state, revoked state, satisfied state

**Control End Reason**:
The reason an Ended Control ceased enforcement, such as Revoked, Released, Satisfied, Expired, or Superseded.
_Avoid_: Control State

**Applicable Controls**:
The independent Controls currently affecting a decision through its Product Arrangement, selected Ledger Accounts, or Payment Device. Their constraints are cumulative, and ending one Control has no effect on any other.
_Avoid_: Merged Control, account status
