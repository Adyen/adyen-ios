# Remove PresentableComponent Usage from Actions

## Objective
Remove any usage of `PresentableComponent` in actions by:
1. Removing `navBarType` from `PresentableComponent` protocol
2. Changing `PresentationDelegate.present(component:)` to `present(viewController:)`
3. Renaming `PresentableComponentWrapper` to `ActionViewWrapper` and removing `PresentableComponent` conformance

## Background Analysis

### Current State
- `navBarType` is defined in `PresentableComponent` protocol but **never consumed** (dead code)
- Action components create `PresentableComponentWrapper` with custom navigation bars that are never used
- DropIn uses `ActionWrapperViewController` which ignores `navBarType` entirely

### Files Affected

| Category | Files |
|----------|-------|
| **Core Protocols** | `PresentableComponent.swift`, `PresentationDelegate.swift` |
| **Wrapper** | `PresentableComponentWrapper.swift` → `ActionViewWrapper.swift` |
| **Action Components** | `VoucherComponent.swift`, `DocumentComponent.swift`, `QRCodeActionComponent.swift`, `AwaitComponent.swift`, `ThreeDS2PlusDAScreenPresenter.swift`, `RedirectComponent.swift` |
| **Unused Types** | `ActionNavigationBar.swift`, `EmptyNavigationBar` |
| **DropIn** | `DropInComponentExtensions.swift`, `ActionPresentationHelper.swift`, `ActionWrapperViewController.swift`, `NavigationDelegate.swift` |
| **Tests** | `PresentationDelegateMock.swift`, `AutoMockable.generated.swift`, various test files |

---

## Implementation Steps

### Step 1: Remove `navBarType` from `PresentableComponent` Protocol

**File:** `Adyen/Core/Core Protocols/PresentableComponent.swift`

**Remove:**
- `AnyNavigationBar` protocol (lines 24-29)
- `NavigationBarType` enum (lines 31-35)
- `navBarType` property from `PresentableComponent` protocol (lines 44-46)
- Default `navBarType` extension (lines 50-56)

**Result:** `PresentableComponent` will only have `viewController` property.

---

### Step 2: Update `PresentationDelegate`

**File:** `Adyen/Core/Core Protocols/PresentationDelegate.swift`

**Change:**
```swift
// Before
func present(component: PresentableComponent)

// After  
func present(viewController: UIViewController)
```

**Note:** This is a **public API breaking change**.

---

### Step 3: Rename and Update `PresentableComponentWrapper`

**File:** `Adyen/Core/Components/Base/PresentableComponentWrapper.swift`

**Changes:**
1. Rename class to `ActionViewWrapper`
2. Remove `: PresentableComponent` from class declaration
3. Remove `navBarType` property
4. Remove `navBarType` parameter from initializer
5. Keep: `viewController`, `component`, `Cancellable`, `FinalizableComponent`, `LoadingComponent`

---

### Step 4: Clean Up Action Components

#### 4a. `VoucherComponent.swift`
- Remove `navBarType()` method
- Remove `PresentableComponentWrapper` creation
- Change to: `presentationDelegate.present(viewController: viewController)`

#### 4b. `DocumentComponent.swift`
- Remove `navBarType()` method
- Remove `PresentableComponentWrapper` creation
- Change to: `presentationDelegate.present(viewController: viewController)`

#### 4c. `QRCodeActionComponent.swift`
- Update `present()` method
- Remove `PresentableComponentWrapper` usage
- Change to: `presentationDelegate.present(viewController: viewController)`

#### 4d. `AwaitComponent.swift`
- Remove `PresentableComponentWrapper` creation
- Change to: `presentationDelegate.present(viewController: viewController)`

#### 4e. `ThreeDS2PlusDAScreenPresenter.swift`
- Update all 5 methods that create `PresentableComponentWrapper`
- Remove `EmptyNavigationBar` class
- Change to: `presentationDelegate?.present(viewController: viewController)`

#### 4f. `RedirectComponent.swift`
- Update `openInAppBrowser()` method
- Change to: `presentationDelegate?.present(viewController: component.viewController)`

---

### Step 5: Clean Up Unused Types

#### 5a. `ActionNavigationBar.swift`
**File:** `AdyenActions/Components/Base/ActionNavigationBar.swift`

Evaluate if still needed. If only used for `navBarType`, delete the file.

#### 5b. `EmptyNavigationBar`
**Location:** `ThreeDS2PlusDAScreenPresenter.swift` (lines 198-200)

Remove the class definition.

---

### Step 6: Update DropIn

#### 6a. `DropInComponentExtensions.swift`
```swift
// Before
public func present(component: PresentableComponent) {
    viewController.present(component.viewController, animated: true)
}

// After
public func present(viewController: UIViewController) {
    self.viewController.present(viewController, animated: true)
}
```

#### 6b. `ActionPresentationHelper.swift`
Update to work with `UIViewController` instead of `PresentableComponent`.

#### 6c. `ActionWrapperViewController.swift`
Update initializer to accept `UIViewController` instead of `PresentableComponent`.

#### 6d. `NavigationDelegate.swift`
Update `NavigationDelegate` typealias if needed.

---

### Step 7: Update Test Mocks

#### 7a. `PresentationDelegateMock.swift`
```swift
// Before
var presentComponentReceivedComponent: PresentableComponent?
func present(component: PresentableComponent)

// After
var presentComponentReceivedViewController: UIViewController?
func present(viewController: UIViewController)
```

#### 7b. `AutoMockable.generated.swift`
Regenerate after protocol changes.

#### 7c. Other test files
Update any tests that use `PresentationDelegate` or `PresentableComponentWrapper`.

---

### Step 8: Format and Verify

1. Run SwiftFormat on all modified files:
   ```bash
   swiftformat Adyen/ AdyenActions/ AdyenDropIn/ Tests/
   ```

2. Build code targets:
   ```bash
   xcodebuild -project Adyen.xcodeproj -scheme Adyen -configuration Debug build
   ```

3. Build test targets:
   ```bash
   xcodebuild -project Adyen.xcodeproj -scheme AdyenTests -configuration Debug build
   ```

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Public API breaking change (`PresentationDelegate`) | **High** | Document in MIGRATION.md |
| Unused code removal may break something | Medium | Thorough testing |
| DropIn action presentation may break | Medium | Test all action types |
| Test compilation failures | Medium | Update all mocks and test files |

---

## Verification Checklist

- [ ] `navBarType` removed from `PresentableComponent`
- [ ] `NavigationBarType` and `AnyNavigationBar` removed
- [ ] `PresentationDelegate.present(viewController:)` updated
- [ ] `PresentableComponentWrapper` renamed to `ActionViewWrapper`
- [ ] All action components updated
- [ ] Unused navigation bar types cleaned up
- [ ] DropIn updated
- [ ] Test mocks updated
- [ ] SwiftFormat applied
- [ ] Code targets compile
- [ ] Test targets compile
