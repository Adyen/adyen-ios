# Payment Component Abstractions Refactor Plan (v6)

## Status

Completed — implementation and verification finished.

## Objective

Clarify the distinction between payment components that provide shopper UI and generic UI-presentable entities by:

1. Renaming `PresentableComponent` to `PresentablePaymentComponent`.
2. Making `PresentablePaymentComponent` refine `PaymentComponent`.
3. Renaming `InstantPaymentComponent` to `GenericPaymentComponent`.
4. Replacing every direct `PaymentComponent, PresentableComponent` conformance with the single `PresentablePaymentComponent` conformance.

## Approved Design Decisions

- `PresentablePaymentComponent` is payment-specific and uses `package` access.
- `AnyDropInComponent` will declare its `viewController` requirement directly rather than refining the payment-only protocol.
- Existing action-component casts to the old generic presentation protocol will be removed or reworked rather than renamed to the payment-specific protocol.
- `InstantPaymentMethod` and `InstantPaymentDetails` retain their names because they model the payment-method domain and public data, not the internal component implementation.

## Access-Control Constraint

`PaymentComponent` is a `package` protocol. Swift does not permit a `public` protocol to refine a `package` protocol.

Therefore, the new protocol must be declared as follows:

```swift
@MainActor
package protocol PresentablePaymentComponent: PaymentComponent {
    var viewController: UIViewController { get }
}
```

This intentionally removes the old public `PresentableComponent` API as part of the v6 abstraction change.

## Implementation Steps

### 1. Establish the new payment-specific protocol

- Rename `Adyen/Core/Core Protocols/PresentableComponent.swift` to `PresentablePaymentComponent.swift`.
- Rename the declaration to `PresentablePaymentComponent` and update its documentation to describe payment-component UI.
- Retain the existing `@MainActor` isolation and `viewController` requirement.
- Keep `Localizable` and `Cancellable` in their current file unless a separate cleanup is justified.

### 2. Update core payment typing

In `Adyen/Core/Core Protocols/PaymentComponent.swift`:

- Change `StoredPaymentComponent` to refine only `PresentablePaymentComponent`.
- Change `PaymentComponentType.regular` from `PaymentComponent & PresentableComponent` to `PresentablePaymentComponent`.
- Move the default regular component `type` implementation from:

```swift
extension PaymentComponent where Self: PresentableComponent
```

to:

```swift
extension PresentablePaymentComponent
```

This eliminates redundant protocol intersections and guarantees that every regular component is also a payment component.

### 3. Convert direct component conformances

Replace every direct declaration of `PaymentComponent, PresentableComponent` with `PresentablePaymentComponent`, retaining unrelated conformances such as `LoadingComponent`, `Localizable`, and `AdyenObserver`.

Direct production conformances include:

- `BACSDirectDebitComponent`
- `CardComponent`
- `GiftCardComponent`
- `UPIComponent`
- `SEPADirectDebitComponent`
- `PayToComponent`
- `PayByBankUSComponent`
- `OnlineBankingComponent`
- `IssuerListComponent`
- `BoletoComponent`
- `BLIKComponent`
- `ApplePayComponent`
- `AbstractPersonalInformationComponent`
- `ACHDirectDebitComponent`
- `CashAppPayComponent`

Indirect conformance coverage must also be checked for stored components and subclasses of `CardComponent` and `AbstractPersonalInformationComponent`.

Remove the redundant explicit SPI imports of `PresentableComponent` from targets that already import `Adyen` and access package APIs.

### 4. Update payment-specific Drop-in and Checkout APIs

Update `PresentableComponent` references in Drop-in routing, container, root state, and component-management APIs to use `PresentablePaymentComponent`.

Key changes:

- In `ComponentManager`, replace `PaymentComponent & PresentableComponent` with `PresentablePaymentComponent`.
- In `ComponentContainerViewModel`, store a `PresentablePaymentComponent` and remove redundant casts to `PaymentComponent` when assigning the payment delegate or cancelling.
- In `CheckoutPaymentComponent`, downcast its internal payment component to `PresentablePaymentComponent` before returning a `viewController`.
- Update corresponding Drop-in tests, test subjects, and payment-component mocks. Rename `PresentableComponentMock` consistently.

### 5. Preserve non-payment UI abstractions without inheriting payment behavior

`AnyDropInComponent` must not refine `PresentablePaymentComponent`, because `DropInComponent` is not a payment component and does not implement the required payment API.

Instead:

- Change `AnyDropInComponent` to refine `Component` directly.
- Add its own `viewController: UIViewController { get }` requirement.
- Keep `DropInComponent` conforming through its existing view-controller implementation.

Remove or rework stale `ActionComponent as? PresentableComponent` casts in Checkout and demo code. No current action component conforms to the old protocol, and renaming those casts to `PresentablePaymentComponent` would incorrectly model actions as payment components.

Action-related comments that mention `PresentableComponent` should be rewritten to refer to view-controller or presentation delegation rather than a payment-only protocol.

### 6. Rename `InstantPaymentComponent` to `GenericPaymentComponent`

- Rename `Adyen/Core/Components/InstantPaymentComponent.swift` and its concrete class declaration.
- Update initializers, typealiases, component builders, and `ReadyToSubmitPaymentComponentDelegate` signatures.
- Move the specialized `.genericComponent` `paymentMethodBehavior` extension in `Adyen/Model/SDKData.swift` to `GenericPaymentComponent`; otherwise the default `.nativeComponent` behavior would apply.
- Update all tests that instantiate, assert on, or name the concrete component.
- Review demo wrapper class and file names that include the obsolete concrete component name. Keep “Instant Payment” in user-facing payment-method descriptions where it remains accurate.

## Documentation and Generated Code

- Remove the old protocol from the public DocC protocol list; the replacement is package-only.
- Correct the stale `guides/v6/README.md` presentation example instead of mechanically renaming it, because `PresentationDelegate` currently presents a `UIViewController`.
- Update Sourcery input protocols that use the renamed type.
- Regenerate `Tests/GeneratedMocks/AutoMockable.generated.swift`; do not hand-edit generated mocks.

Regenerate mocks with:

```bash
xcodebuild -project Adyen.xcodeproj -scheme GenerateSourcery build
```

## Verification

1. Run SwiftFormat on every modified Swift file.
2. Confirm no old concrete or protocol symbol remains using repository-wide searches for `PresentableComponent` and `InstantPaymentComponent`.
3. Run focused tests covering Core, Drop-in, Checkout, payment-component mocks, and generic-payment behavior.
4. Run the `UnitTests` scheme on an available iOS simulator:

```bash
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'
```

5. Review the final diff to confirm generated mocks, documentation, and source-file renames are included without unrelated formatting changes.
