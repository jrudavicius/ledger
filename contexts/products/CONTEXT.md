# Products

The Products context defines versioned financial-product rules and binds opened product instances to exact definitions. It gives product meaning to external Ledger Accounts without making Ledger accounting facts depend on mutable product configuration.

## Language

**Product Definition**:
An immutable, version-addressed specification of a financial product's rules, Product Capabilities, Ledger Account Blueprint, and default term values. Everyday, multi-currency, and credit offerings are Product Definitions rather than Ledger Account classifications.
_Avoid_: Account type, Account Classification, mutable Product

**Product Capability**:
A named product behavior supported by an exact Product Definition, such as making payments or accessing an overdraft. It describes what the product offers, not whether a particular operation is currently permitted.
_Avoid_: Permission, Control, Ledger primitive

**Ledger Account Blueprint**:
The part of a Product Definition that describes the Ledger Account structure required by its arrangements. It is composed of Ledger Account Requirements and is not itself a Ledger Account.
_Avoid_: Template Account, Chart of Accounts

**Ledger Account Requirement**:
One product-specific-purpose slot in a Ledger Account Blueprint, including its Asset applicability, prescribed Account Role and Normal Side, and whether it uses a Balance Floor, Balance Ceiling, or no bound. An Arrangement satisfies it through concrete Ledger Account Assignments, with permitted bound values supplied by Arrangement Terms.
_Avoid_: Account Classification, Ledger Account

**Product Arrangement**:
An opened product instance bound to an exact Product Definition, with its own Arrangement Terms and Ledger Account Assignments.
_Avoid_: Ledger Account, Product Definition, customer account

**Arrangement Terms**:
The actual term values governing one Product Arrangement, based on the bound Product Definition's defaults and any selections or overrides that definition permits.
_Avoid_: Product defaults, Ledger Account properties

**Ledger Account Assignment**:
A mapping from one Product Arrangement's product-specific purpose and concrete Asset to an external Ledger Account. The assigned Account's Asset, Account Role, Normal Side, and configured balance-bound policy satisfy the corresponding Ledger Account Requirement and Arrangement Terms.
_Avoid_: Account alias, Payment Device Link, Account Classification
