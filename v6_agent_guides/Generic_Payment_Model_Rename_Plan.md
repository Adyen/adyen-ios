# Generic Payment Model Rename Plan (v6)

## Status

Implemented. This supersedes the prior model-only plan with a project-wide cleanup of stale `instant` names that refer to the generic payment component or model.

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
3. Rename stale local symbols that identify the generic model or component: `instantPaymentMethod` in `CheckoutComponentBuilder`, the two demo `instantPaymentComponent` helpers, the generic component builder test name, and the Pay by Bank fixture/test names that assert decoding into `GenericPaymentMethod`.
4. Update accompanying demo comments and the Demo README so they describe generic payment methods and the generic payment component.
5. Retain shopper-facing and behavioral uses of “instant”, including the Drop-in single-instant-payment-method behaviour, product copy/localizations, generic uses of “instantiated” or “instantly”, and historical v5 API names in migration documentation.
6. Retain the `GenericPaymentComponent` implementation and its `.genericComponent` behavior.

## Planned replacements

| Location | Current | Replacement |
|---|---|---|
| `AdyenCheckout/Component/CheckoutComponentBuilder.swift` | `instantPaymentMethod` | `genericPaymentMethod` |
| Generic payment demo examples | `instantPaymentComponent` and comments | `genericPaymentComponent` and generic-payment wording |
| `Tests/UnitTests/AdyenCheckout/CheckoutComponentBuilderTests.swift` | `test_build_withInstantPaymentMethod_returnsGenericPaymentComponent` | `test_build_withGenericPaymentMethod_returnsGenericPaymentComponent` |
| Pay by Bank dummy data and decoding tests | `payByBankInstant` and `decodesAsInstant` | names that identify the generic model |
| `Demo/README.md` | “Instant payment methods” | “Generic payment methods” |

## Verification

- Run SwiftFormat on all edited Swift files.
- Verify no production or DocC references to the old public model names remain.
- Search for the stale generic-model identifiers (`instantPaymentMethod`, `instantPaymentComponent`, `payByBankInstant`, and `decodesAsInstant`) and confirm none remain.
- Run focused decoding, QR-code, Pay by Bank US, and generic payment component tests.
- Run the full `UnitTests` and relevant `IntegrationUIKitTests` schemes.
