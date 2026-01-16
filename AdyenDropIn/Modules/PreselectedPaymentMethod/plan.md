# PreselectedPaymentMethodComponent Migration Plan

## Overview

Migrate all logic from `PreselectedPaymentMethodComponent` to the MVVM-Router architecture (`PreselectedPaymentMethodRouter`, `PreselectedPaymentMethodViewModel`, `PreselectedPaymentMethodViewController`).

### Current State
- **PreselectedPaymentMethodComponent**: Contains UI creation (FormViewController, form items), loading state management, localization, and delegate callbacks.
- **PreselectedPaymentMethodViewModel**: Creates and holds the Component, delegates to it, handles business logic.
- **PreselectedPaymentMethodViewController**: Embeds Component's viewController as a child.

### Target State
- **PreselectedPaymentMethodComponent**: Deleted.
- **PreselectedPaymentMethodViewModel**: Owns all data/state (form items, loading state, localization).
- **PreselectedPaymentMethodViewController**: Builds and owns the FormViewController directly.

---

## Verification Strategy

After each task, run the following verification steps:

1. **Build Check**: Ensure code compiles
2. **Unit Tests**: Run unit tests using XcodeBuildMCP

### Running Tests with XcodeBuildMCP

XcodeBuildMCP is an MCP server that provides tools to build and test Xcode projects.

**Step 1: List available simulators**

```
mcp0_list_sims
```

**Step 2: Set session defaults (run once at the start)**

```
mcp0_session-set-defaults:
  projectPath: /Users/robertd/Desktop/Workspace/Projects/checkout/1_adyen-ios/Adyen.xcodeproj
  scheme: UnitTests
  simulatorName: iPhone 16
  useLatestOS: true
```

**Step 3: Build for simulator**

```
mcp0_build_sim
```

**Step 4: Run unit tests**

```
mcp0_test_sim
```

**Run a specific test class:**

```
mcp0_test_sim:
  extraArgs: ["-only-testing:UnitTests/TestClassName"]
```

### Alternative: Direct xcodebuild Commands

If XcodeBuildMCP is not available, use these commands directly:

```bash
# List simulators
xcrun simctl list devices available

# Run unit tests
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'

# Run specific test class
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>' -only-testing:UnitTests/TestClassName
```

**Note:** Do not use `swift test` - it doesn't work well with the Xcode project structure.

---

## Migration Tasks

### Phase 1: Add Properties to ViewModel

---

#### task-1: Add payment method properties to ViewModel

**Scope**: Add `paymentMethod`, `apiContext`, and `context` computed properties to ViewModel.

**Description**: Move the `PaymentMethodAware` conformance properties from Component to ViewModel. These are derived from the existing `component` property.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal var paymentMethod: PaymentMethod { component.paymentMethod }
internal var apiContext: APIContext { component.context.apiContext }
internal var context: AdyenContext { component.context }
```

**Expected Output**: ViewModel exposes `paymentMethod`, `apiContext`, and `context` properties.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-2: Add style properties to ViewModel

**Scope**: Add `style` and `listItemStyle` properties to ViewModel.

**Description**: Store the form component style and list item style in the ViewModel, extracted from configuration.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal let style: FormComponentStyle
internal let listItemStyle: ListItemStyle
```

Initialize in `init`:
```swift
self.style = configuration.style.formComponent
self.listItemStyle = configuration.style.listComponent.listItem
```

**Expected Output**: ViewModel owns style configuration.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-3: Add localizationParameters property to ViewModel

**Scope**: Add `localizationParameters` property to ViewModel.

**Description**: Move localization parameters storage from Component to ViewModel.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal var localizationParameters: LocalizationParameters?
```

Initialize in `init`:
```swift
self.localizationParameters = configuration.localizationParameters
```

**Expected Output**: ViewModel owns localization parameters.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-4: Add title property to ViewModel

**Scope**: Add `title` property to ViewModel.

**Description**: Store the title in ViewModel (already passed to init, just needs to be stored as a property).

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal let title: String
```

Initialize in `init`:
```swift
self.title = title
```

**Expected Output**: ViewModel exposes `title` property.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

### Phase 2: Add Form Item Factories to ViewModel

---

#### task-5: Add listItem factory method to ViewModel

**Scope**: Add method to create the `ListItem` for the preselected payment method.

**Description**: Move the `listItem` lazy property logic from Component to a factory method in ViewModel.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal func makeListItem() -> ListItem {
    let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
    let imageURL = LogoURLProvider.logoURL(
        withName: displayInformation.logoName,
        environment: context.apiContext.environment
    )
    return ListItem(
        title: displayInformation.title,
        subtitle: displayInformation.subtitle,
        icon: .init(url: imageURL),
        style: listItemStyle,
        identifier: ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "defaultComponent"),
        accessibilityLabel: displayInformation.accessibilityLabel
    )
}
```

**Expected Output**: ViewModel can create ListItem.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-6: Add submitButtonItem factory method to ViewModel

**Scope**: Add method to create the submit button form item.

**Description**: Move the `submitButtonItem` lazy property logic from Component to a factory method in ViewModel.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal func makeSubmitButtonItem() -> FormButtonItem {
    let item = FormButtonItem(style: style.mainButtonItem)
    item.title = localizedSubmitButtonTitle(
        with: context.payment?.amount,
        style: .immediate,
        localizationParameters
    )
    item.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "submitButton")
    item.buttonSelectionHandler = { [weak self] in
        guard let self else { return }
        self.didProceed(with: self.component)
    }
    return item
}
```

**Expected Output**: ViewModel can create submit button.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-7: Add openAllButtonItem factory method to ViewModel

**Scope**: Add method to create the "open all payment methods" button.

**Description**: Move the `openAllButtonItem` lazy property logic from Component to a factory method in ViewModel.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal func makeOpenAllButtonItem() -> FormButtonItem {
    let item = FormButtonItem(style: style.secondaryButtonItem)
    item.title = localizedString(.dropInPreselectedOpenAllTitle, localizationParameters)
    item.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "openAllButton")
    item.buttonSelectionHandler = { [weak self] in
        self?.didRequestAllPaymentMethods()
    }
    return item
}
```

**Expected Output**: ViewModel can create open-all button.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-8: Add separator factory method to ViewModel

**Scope**: Add method to create the separator form item.

**Description**: Move the `separator` lazy property logic from Component to a factory method in ViewModel.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal func makeSeparatorItem() -> FormSeparatorItem {
    let separator = FormSeparatorItem(color: style.separatorColor ?? UIColor.Adyen.componentSeparator)
    separator.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "separator")
    return separator
}
```

**Expected Output**: ViewModel can create separator.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-9: Add footnoteItem factory method to ViewModel

**Scope**: Add method to create the optional footnote label item.

**Description**: Move the `footnoteItem` lazy property logic from Component to a factory method in ViewModel.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal func makeFootnoteItem() -> FormLabelItem? {
    guard let footnoteText = paymentMethod
        .displayInformation(using: localizationParameters)
        .footnoteText else { return nil }
    let item = FormLabelItem(text: footnoteText, style: style.footnoteLabel)
    item.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "footnote")
    return item
}
```

**Expected Output**: ViewModel can create footnote item.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

### Phase 3: Add Loading State to ViewModel

---

#### task-10: Add form item references to ViewModel

**Scope**: Add stored properties for form items that need state updates.

**Description**: Store references to `submitButtonItem` and `openAllButtonItem` so loading state can be toggled.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
private var submitButtonItem: FormButtonItem?
private var openAllButtonItem: FormButtonItem?
```

**Expected Output**: ViewModel can hold references to mutable form items.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-11: Update startLoading to use stored form items

**Scope**: Modify `startLoading` to update stored form item references.

**Description**: Change `startLoading` to directly manipulate the stored form items instead of delegating to Component.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
private func startLoading(for component: PaymentComponent) {
    guard component === self.component else { return }
    submitButtonItem?.showsActivityIndicator = true
    openAllButtonItem?.enabled = false
}
```

**Expected Output**: Loading state managed directly by ViewModel.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-12: Update stopLoading to use stored form items

**Scope**: Modify `stopLoading` to update stored form item references.

**Description**: Change `stopLoading` to directly manipulate the stored form items instead of delegating to Component.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
private func stopLoading() {
    submitButtonItem?.showsActivityIndicator = false
    openAllButtonItem?.enabled = true
}
```

**Expected Output**: Loading state managed directly by ViewModel.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

### Phase 4: Update ViewModel Protocol

---

#### task-13: Expand ViewModel protocol with form item accessors

**Scope**: Add form item factory methods to the protocol.

**Description**: Update `PreselectedPaymentMethodViewModelProtocol` to expose form item creation methods.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal protocol PreselectedPaymentMethodViewModelProtocol {
    var title: String { get }
    var style: FormComponentStyle { get }
    var localizationParameters: LocalizationParameters? { get }
    func makeListItem() -> ListItem
    func makeSubmitButtonItem() -> FormButtonItem
    func makeOpenAllButtonItem() -> FormButtonItem
    func makeSeparatorItem() -> FormSeparatorItem
    func makeFootnoteItem() -> FormLabelItem?
    func cancel()
    func setFormItemReferences(submitButton: FormButtonItem, openAllButton: FormButtonItem)
}
```

**Expected Output**: Protocol defines all methods needed by ViewController.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-14: Add setFormItemReferences method to ViewModel

**Scope**: Add method for ViewController to pass back form item references.

**Description**: ViewController creates form items and passes references back to ViewModel for state management.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**:
```swift
internal func setFormItemReferences(submitButton: FormButtonItem, openAllButton: FormButtonItem) {
    self.submitButtonItem = submitButton
    self.openAllButtonItem = openAllButton
}
```

**Expected Output**: ViewModel can receive form item references from ViewController.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

### Phase 5: Update ViewController to Build Form

---

#### task-15: Add FormViewController property to ViewController

**Scope**: Add a lazy `formViewController` property to ViewController.

**Description**: ViewController will own and create the FormViewController directly.

**File**: `PreselectedPaymentMethodViewController.swift`

**Changes**:
```swift
private lazy var formViewController: FormViewController = {
    FormViewController(
        scrollEnabled: true,
        style: viewModel.style,
        localizationParameters: viewModel.localizationParameters
    )
}()
```

**Expected Output**: ViewController owns FormViewController.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-16: Add form item setup method to ViewController

**Scope**: Add method to populate FormViewController with items.

**Description**: Create a method that builds and appends all form items to the FormViewController.

**File**: `PreselectedPaymentMethodViewController.swift`

**Changes**:
```swift
private func setupFormItems() {
    let listItem = viewModel.makeListItem()
    let submitButton = viewModel.makeSubmitButtonItem()
    let openAllButton = viewModel.makeOpenAllButtonItem()
    
    formViewController.append(listItem)
    formViewController.append(submitButton)
    if let footnoteItem = viewModel.makeFootnoteItem() {
        formViewController.append(footnoteItem.padding())
    }
    formViewController.append(FormSpacerItem())
    formViewController.append(viewModel.makeSeparatorItem())
    formViewController.append(openAllButton)
    formViewController.append(FormSpacerItem(numberOfSpaces: 2))
    
    viewModel.setFormItemReferences(submitButton: submitButton, openAllButton: openAllButton)
}
```

**Expected Output**: ViewController can build the form.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-17: Update setupPaymentMethodView to use formViewController

**Scope**: Modify `setupPaymentMethodView` to embed `formViewController` instead of `viewModel.paymentMethodView`.

**Description**: Replace the child view controller embedding to use the locally created FormViewController.

**File**: `PreselectedPaymentMethodViewController.swift`

**Changes**:
```swift
private func setupPaymentMethodView() {
    setupFormItems()
    
    formViewController.willMove(toParent: self)
    addChild(formViewController)
    view.addSubview(formViewController.view)
    formViewController.didMove(toParent: self)
    formViewController.view.adyen.anchor(inside: view)
}
```

**Expected Output**: ViewController embeds its own FormViewController.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-18: Update setupNavigationItem to use viewModel.title

**Scope**: Modify `setupNavigationItem` to use `viewModel.title` directly.

**Description**: Replace `viewModel.paymentMethodView.title` with `viewModel.title`.

**File**: `PreselectedPaymentMethodViewController.swift`

**Changes**:
```swift
private func setupNavigationItem() {
    navigationItem.title = viewModel.title
    setupCancelButton()
}
```

**Expected Output**: Navigation title comes from ViewModel.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

### Phase 6: Remove Component Dependency from ViewModel

---

#### task-19: Remove preselectedPaymentMethodComponent property from ViewModel

**Scope**: Delete the `preselectedPaymentMethodComponent` property.

**Description**: Remove the Component instance from ViewModel since all its functionality is now in ViewModel/ViewController.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**: Remove:
```swift
private let preselectedPaymentMethodComponent: PreselectedPaymentMethodComponent
```

And remove its initialization in `init`.

**Expected Output**: ViewModel no longer holds Component.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-20: Remove paymentMethodView from ViewModel protocol

**Scope**: Remove `paymentMethodView` property from protocol and implementation.

**Description**: This property is no longer needed since ViewController builds the form directly.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**: Remove from protocol:
```swift
var paymentMethodView: UIViewController { get }
```

Remove implementation:
```swift
internal var paymentMethodView: UIViewController {
    preselectedPaymentMethodComponent.viewController
}
```

**Expected Output**: Protocol no longer exposes paymentMethodView.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-21: Remove PreselectedPaymentMethodComponentDelegate conformance

**Scope**: Remove delegate conformance from ViewModel.

**Description**: ViewModel no longer needs to conform to `PreselectedPaymentMethodComponentDelegate` since it handles actions directly.

**File**: `PreselectedPaymentMethodViewModel.swift`

**Changes**: Remove `: PreselectedPaymentMethodComponentDelegate` from class declaration.

**Expected Output**: ViewModel doesn't conform to Component delegate.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

### Phase 7: Cleanup

---

#### task-22: Delete PreselectedPaymentMethodComponent.swift

**Scope**: Remove the entire Component file.

**Description**: Delete `PreselectedPaymentMethodComponent.swift` as all its functionality has been migrated.

**File**: `PreselectedPaymentMethodComponent.swift`

**Changes**: Delete file.

**Expected Output**: Component file no longer exists.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
3. No references remain: `grep -r "PreselectedPaymentMethodComponent" AdyenDropIn/`

---

#### task-23: Remove Component import from Assembler if needed

**Scope**: Verify Assembler doesn't reference deleted Component.

**Description**: Ensure `PreselectedPaymentMethodAssembler.swift` doesn't import or reference the deleted Component.

**File**: `PreselectedPaymentMethodAssembler.swift`

**Changes**: Review and remove any references to `PreselectedPaymentMethodComponent`.

**Expected Output**: Assembler compiles without Component references.

**Verification**:
1. Code compiles: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-24: Update project file to remove Component

**Scope**: Remove `PreselectedPaymentMethodComponent.swift` from Xcode project.

**Description**: Update `project.pbxproj` to remove references to the deleted file.

**File**: `Adyen.xcodeproj/project.pbxproj`

**Changes**: Remove file reference entries for `PreselectedPaymentMethodComponent.swift`.

**Expected Output**: Project builds without the Component file.

**Verification**:
1. Build succeeds: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
2. Unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

#### task-25: Run SwiftFormat on modified files

**Scope**: Format all modified files.

**Description**: Run SwiftFormat on the PreselectedPaymentMethod module files to ensure code style compliance.

**Command**: 
```bash
swiftformat AdyenDropIn/Modules/PreselectedPaymentMethod/
```

**Expected Output**: All files formatted according to project standards.

**Verification**:
1. `swiftformat --lint .` passes
2. Final build succeeds: `xcodebuild build -project Adyen.xcodeproj -scheme AdyenDropIn -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`
3. All unit tests pass: `xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'`

---

## Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| 1 | task-1 to task-4 | Add properties to ViewModel |
| 2 | task-5 to task-9 | Add form item factories to ViewModel |
| 3 | task-10 to task-12 | Add loading state management to ViewModel |
| 4 | task-13 to task-14 | Update ViewModel protocol |
| 5 | task-15 to task-18 | Update ViewController to build form |
| 6 | task-19 to task-21 | Remove Component dependency from ViewModel |
| 7 | task-22 to task-25 | Cleanup and delete Component |

**Total Tasks**: 25  
**Estimated Lines per Task**: ≤10
