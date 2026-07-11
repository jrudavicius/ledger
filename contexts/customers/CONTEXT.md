# Customers

The Customers context represents the individuals and legal entities served by an Organization and their relationships to Product Arrangements in the Products context.

## Language

**Customer**:
An individual or legal entity served and identified within one Organization's scope, with an identity independent of any Product Arrangement or Ledger Account.
_Avoid_: Organization, User, Account

**Stakeholder**:
The role a Customer plays as a party to one Product Arrangement belonging to the same Organization. A Customer may be a Stakeholder of multiple Product Arrangements, and multiple distinct Customers may be Stakeholders of the same Product Arrangement.
_Avoid_: Account Role, User, generic interested party

**Joint Arrangement**:
A Product Arrangement for which at least two distinct Customers are Stakeholders. Joint account may be used in customer-facing copy, but jointness is not a Ledger Account type, Account Role, or Normal Side.
_Avoid_: Joint Account in domain language, Account type, Joint Customer
