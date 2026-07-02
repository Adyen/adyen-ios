# Action ViewController Unification Plan

## Context

Actions do not use `PresentableComponent` anymore — all their presentation is handled via view controllers directly.

The goal is to unify how action view controllers are structured: every action component should use a single `ActionViewController` (renamed from `ADYViewController`) that wraps a dedicated action view.

---

## Step 1 — Rename `ADYViewController` → `ActionViewController`

**File:** `AdyenUI/UI/View Controllers/ADYViewController.swift` → `ActionViewController.swift`

**Changes:**
- Rename the file
- Rename the class from `ADYViewController` to `ActionViewController`
- Update all call sites:
  - `AdyenActions/Components/Voucher/VoucherComponent.swift`
  - `AdyenActions/Components/Document/DocumentComponent.swift`
  - `AdyenDropIn/Modules/DropInFlowManager.swift`
  - `Tests/IntegrationTests/Actions Tests/Voucher/DokuVoucherUITests.swift`
  - `Tests/IntegrationTests/Actions Tests/ActionComponent/CheckoutActionComponentTests.swift`
  - `Tests/IntegrationTests/Components Tests/BACS Direct Debit/DocumentComponentTests.swift`
  - `Tests/IntegrationTests/Actions Tests/Voucher/BoletoVoucherShareableVoucherViewProviderTests.swift`
  - `Tests/IntegrationTests/Actions Tests/Voucher/EContextATMShareableVoucherViewProviderTests.swift`
  - `Tests/IntegrationTests/Actions Tests/Voucher/EContextStoresVoucherViewControllerProviderTests.swift`
  - `Tests/IntegrationTests/Actions Tests/Voucher/MultibancoShareableVoucherViewProviderTests.swift`
  - `Tests/IntegrationTests/Actions Tests/Voucher/OXXOShareableVoucherViewProviderTests.swift`
  - `Tests/IntegrationTests/DropIn Tests/DropInTests.swift`

---

## Step 2 — Turn `AwaitViewController` into `AwaitView`

**Goal:** Make `AwaitView` self-contained so `ActionViewController(view: awaitView)` just works.

**Current structure:**
- `AwaitView` — flat layout: icon, message label, spinner (no safe-area centering)
- `AwaitViewController` — wraps `AwaitView` in a `containerView`, anchors container to `safeAreaLayoutGuide`, centers `AwaitView` vertically within the container

**Changes:**
- Move the centering layout from `AwaitViewController` into `AwaitView`:
  - Remove the `containerView` intermediate layer
  - Anchor the view's own content relative to `safeAreaLayoutGuide` (or use internal padding)
  - Center content vertically
- Delete `AdyenActions/UI/View Controllers/Await/AwaitViewController.swift`
- Update `AwaitComponent.handle(_:)`:

```swift
// Before
let viewController = AwaitViewController(viewModel: viewModel, style: configuration.style)
presentationDelegate.present(viewController: viewController)

// After
let awaitView = AwaitView(viewModel: viewModel, style: configuration.style)
let viewController = ActionViewController(view: awaitView)
presentationDelegate.present(viewController: viewController)
```

---

## Step 3 — Remove `VoucherViewController`

**Observation:** `VoucherComponent.handle(_:)` already creates an `ActionViewController(view: voucherView)` directly. `VoucherViewController` is dead code — it is not referenced anywhere in the production code.

**Changes:**
- Verify no remaining references to `VoucherViewController`
- Delete `AdyenActions/UI/View Controllers/Voucher/VoucherViewController.swift`

---

## Out of Scope (for this plan)

- **`QRCodeViewController`**: Has significant layout code (scroll view, multiple subviews, observable bindings). Migrating it to a standalone `QRCodeActionView` is a separate, more involved task.
- **DA view controllers** (`DAApprovalViewController`, `DAErrorViewController`, `DARegistrationViewController`): To be migrated separately.
