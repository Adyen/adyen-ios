# Generic Payment Model Rename Plan (v6)

## Status

Approved for implementation.

## Objective

Rename the public payment-method models that back the generic payment component so their API names align with `GenericPaymentComponent`.

## Public API Rename

| Current | New |
|---|---|
| `InstantPaymentMethod` | `GenericPaymentMethod` |
| `StoredInstantPaymentMethod` | `StoredGenericPaymentMethod` |
| `InstantPaymentDetails` | `GenericPaymentDetails` |

This is a clean v6 rename. The old public names will not be retained as deprecated aliases.

## Scope

1. Rename the source files and public model declarations.
2. Update payment-method decoding, `AnyPaymentMethod` cases, and the internal payment-method decoder names.
3. Update builders, aliases, details producers, tests, DocC, and migration documentation.
4. Retain shopper-facing terminology such as `Instant/Redirect Payment`, where it describes a payment category rather than an SDK model type.
5. Retain the `GenericPaymentComponent` implementation and its `.genericComponent` behavior.

## Verification

- Run SwiftFormat on all edited Swift files.
- Verify no production or DocC references to the old public model names remain.
- Run focused decoding, QR-code, Pay by Bank US, and generic payment component tests.
- Run the full `UnitTests` and relevant `IntegrationUIKitTests` schemes.
