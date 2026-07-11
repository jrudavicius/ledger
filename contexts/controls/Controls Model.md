# Controls Model

> [!status]
> Conceptual model - not yet implemented.

This note is a reference view of the documented Controls model. It separates authoritative Control concepts from target-owned decisions and facts; it is not a code or persistence design.

## Class Diagram

~~~mermaid
classDiagram
  direction LR

  class Control {
    identity
    rationale
    effectivePeriod
  }
  class ControlConstraint {
    <<closed_union>>
  }
  class ProhibitAction
  class ReserveAmount {
    amount
  }
  class UsageLimit {
    maximum
  }
  class ControlledAction
  class LimitMeasure {
    <<closed_union>>
    Count
    AssetAmount
  }
  class LimitWindow {
    boundaryRule
    timeZone
  }
  class UsageBasis {
    <<closed_union>>
    GrossAcceptedUsage
    OutstandingUsage
  }
  class LimitUsage {
    consumed
  }
  class ControlAuthority
  class ControlSourceReference
  class ControlChange
  class ControlState {
    Scheduled
    Active
    Ended
  }
  class Account {
    <<external_reference>>
  }
  class ProductArrangement {
    <<external_reference>>
  }
  class ProductCapability {
    <<external_reference>>
  }
  class PaymentDevice {
    <<external_reference>>
  }
  class Asset {
    <<external_reference>>
  }
  class ApplicableControls {
    <<derived_set>>
  }
  class ControlEvaluation {
    <<decision>>
  }
  class TargetDecisionOrder {
    <<ordering_rule>>
  }

  ControlConstraint <|-- ProhibitAction
  ControlConstraint <|-- ReserveAmount
  ControlConstraint <|-- UsageLimit
  Control --> ControlConstraint : constraint
  Control --> ControlAuthority : source authority
  Control --> ControlSourceReference : mandate reference
  Control --> ControlState : lifecycle phase
  Control --> ProductArrangement : target option
  Control --> Account : target option
  Control --> PaymentDevice : target option
  Control --> ControlChange : ordered changes
  ProhibitAction --> ControlledAction : denies
  UsageLimit --> ControlledAction : measures
  UsageLimit --> LimitMeasure : uses
  UsageLimit --> LimitWindow : accumulates within
  UsageLimit --> UsageBasis : recognizes by
  UsageLimit ..> LimitUsage : usage per window
  LimitMeasure ..> Asset : amount names one
  ControlledAction ..> ProductCapability : may name
  ApplicableControls ..> Control : currently affecting target
  ControlEvaluation ..> ApplicableControls : evaluates
  ControlEvaluation ..> LimitUsage : reads and consumes
  ControlEvaluation ..> TargetDecisionOrder : respects
~~~

The target associations form an exclusive-or: every Control targets exactly one Product Arrangement, Account, or Payment Device, never none or several.

## Concept Reference

### Control

An independently enforceable constraint with its own identity, rationale, source authority, lifecycle, effective period, exactly one target, and exactly one typed Control Constraint. It constrains decisions but never grants permission, changes a target lifecycle by itself, or rewrites accepted work.

### Control Constraint

A closed union with three variants: Prohibit Action, Reserve Amount, and Usage Limit. A Control carries exactly one variant so mandates can be adjusted and ended independently without a generic expression language.

### Controlled Action

A stable name for a decision owned by a target context. Examples include invoking an outward Product Capability, accepting an Account-decreasing Transaction, using a Payment Device, and transitioning an Account from Opening to Open.

### Prohibit Action

A Control Constraint that denies a matching Controlled Action while Active. A denial leaves target state unchanged; an Account Opening Block therefore leaves the Account in Opening.

### Reserve Amount

An Account-only Control Constraint that encumbers Decrease Capacity in the Account Asset without changing Posted Balance. It may exceed current capacity and continues to encumber future capacity until adjusted or ended; it does not affect Increase Capacity.

### Usage Limit

A Control Constraint that caps a count or single-Asset amount for one Controlled Action in each Limit Window. A candidate passes only when current Limit Usage plus the candidate does not exceed the maximum.

### Limit Window

The half-open recurring interval used by a Usage Limit, assigned by service acceptance time and defined by its boundary rule and time zone. Daily and monthly limits use explicit calendar-day and calendar-month windows rather than server-local labels.

### Usage Basis

The typed rule for which accepted use remains counted. Gross Accepted Usage never decreases after a later void or refund; Outstanding Usage changes only through an explicit release of unused consumption.

### Limit Usage

The authoritative recognized consumption of one Usage Limit in one window. Acceptance records usage in the same decision that admits the action, and an idempotent retry does not consume it again.

Whether a void, reversal, or correction releases usage follows the declared Usage Basis and is never inferred from Ledger balance effects.

### Control Evaluation

The decision against every Active applicable Control and relevant Limit Usage when a Controlled Action is first accepted. A later Control does not reinterpret an accepted action or Pending Transaction.

### Target Decision Order

The deterministic order among Control changes, target decisions, and Limit Usage consumption for each target. Concurrent candidates cannot both spend the same remaining limit, and acceptance uses state that remains valid through commit.

### Control Adjustment

An explicit Control Change to an adjustable value such as a Reserve Amount or Usage Limit threshold. Identity, target, constraint type, source authority, and original terms stay immutable; changing one requires a new Control.

### Arrangement Freeze

A configured Product Arrangement Control whose Prohibit Action constraint denies named Product Capabilities such as customer-initiated outward movement. It changes no Arrangement Terms, Assignments, Account lifecycle, or balance.

### Customer-Requested Arrangement Freeze

An Arrangement Freeze requested by a Customer who is a Stakeholder and applied by an authorized support actor. The requesting Customer and applying actor belong in Control History.

### Account Opening Block

A configured Account Control whose Prohibit Action constraint denies Opening-to-Open. The Account remains Opening until the Control ends and its Accounts-owned Account Opening Gate is otherwise satisfied.

### Control Authority and History

Control Authority is the source of mandate, distinct from the performing actor. Control Source Reference identifies the authority-scoped request, legal order, compliance finding, or product rule; original terms and ordered Control Changes form immutable Control History.

### Applicable Controls

The derived set of independent Controls affecting a decision through its Product Arrangement, selected Accounts, or Payment Device. All applicable constraints must pass, and ending one has no effect on another.

## Scenario Mapping

| Scenario | Target | Constraint | Authority and history |
|---|---|---|---|
| Support prohibits outgoing transactions at a Customer request | Product Arrangement | Prohibit Action on outward Product Capabilities | Customer requester and support actor are recorded |
| A legal order freezes a specific amount | Ledger Account | Reserve Amount in the Account Asset | Legal source reference governs adjustment and release |
| Daily or monthly activity cap | Arrangement, Account, or Payment Device | Usage Limit with explicit window and count or single-Asset amount | Applicable product, risk, customer, or compliance authority is recorded |
| Compliance prevents an Opening Account from becoming Open | Ledger Account | Prohibit Action on Opening-to-Open | Compliance authority and affected Customer reference stay in Controls so Accounts remains Customer-agnostic |

## Invariants

- Every Control targets exactly one Product Arrangement XOR one Account XOR one Payment Device.
- Every Control carries exactly one constraint from the closed Prohibit Action, Reserve Amount, or Usage Limit union.
- Free text never controls enforcement; a target or constraint-type change requires a new Control.
- Reserve Amount is Account-only and uses the Account Asset.
- An amount-based Usage Limit names exactly one Asset; Controls performs no implicit cross-Asset valuation.
- A Usage Limit declares exactly one Usage Basis, and its window is selected by service acceptance time rather than a caller-supplied effective time.
- A candidate exactly at the Usage Limit is allowed; only an amount or count above it is denied.
- Accepting a limited action and consuming all applicable Limit Usage succeed or fail together; retries never double-consume.
- Original identity, target, source authority, constraint type, and terms remain immutable; Control Changes are appended in order.
- Target decisions evaluate all applicable Active Controls when first accepted and never apply later Controls retroactively.
- Applicable Controls are independent and cumulative; one action may need to pass daily and monthly limits together.
- Prohibit Action permission, Reserve Amount encumbrance, Usage Limit headroom, and Ledger directional capacities are distinct decisions.

## Unresolved Questions and Overstatement Risks

- The target-reference and cross-context consistency mechanisms are not designed.
- Control Authority types, the complete Controlled Action catalogue, effective-period boundaries, and end reasons are incomplete.
- Each target context must define the canonical usage amount for its Controlled Actions; Controls must not count balancing Journal Postings as separate customer usage.
- The exact release events and partial-release rules for Outstanding Usage need a concrete catalogue.
- Limit Window inclusivity and Organization time-zone selection need concrete rules.
- Control History, Applicable Controls, and Limit Usage do not imply persistence classes or aggregate boundaries.
- Freeze and opening-block patterns are configurations, not entity subclasses.
- Multi-Asset amount holds or limits require coordinated per-Asset Controls or a separately decided valuation model.
- The Accounts lifecycle does not yet define how a Pending or Opening Account that will never open is abandoned.
- Aggregate, event-stream, persistence, and atomicity boundaries remain unselected.

## Related

- [[Domain Model Index]]
- [[CONTEXT-MAP|Context Map]]
- [[contexts/controls/CONTEXT|Controls Context]]
- [[contexts/controls/docs/adr/0004-use-typed-restriction-effects|Superseded: Use Typed Restriction Effects]]
- [[contexts/controls/docs/adr/0009-use-typed-controls-for-operational-constraints|Use Typed Controls for Operational Constraints]]
- [[contexts/accounts/Accounts Model|Accounts Model]]
- [[contexts/products/Products Model|Products Model]]
- [[contexts/customers/Customers Model|Customers Model]]
- [[contexts/payment-instruments/Payment Instruments Model|Payment Instruments Model]]
