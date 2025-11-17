# AGENTS.md

This file provides guidance to LLMs when working with code in this repository.

**IMPORTANT:** This is the v6 major version branch. All v6 development PRs should target `v6_base`.

## Project Overview

Adyen iOS is a modular payment SDK providing both Drop-in (all-in-one) and Components (individual payment methods) integration options. The SDK handles payment method selection, details entry, 3DS authentication, and various payment actions.

**Minimum Requirements:**
- iOS 12.0+
- Xcode 15.0+
- Swift 5.7+

**Main Branch for v6 PRs:** `v6_base`

## Architecture

### Module Structure

The SDK is organized into focused, independent modules:

- **Adyen**: Core module with fundamental types (`PaymentMethod`, `Component` protocols, `AdyenContext`, networking, analytics)
- **AdyenUI**: Reusable UI components (forms, lists, styles, theming). Provides `FormViewController`, form items, and the style system
- **AdyenCard**: Card payment components including encryption, validation, and 3DS2 handling
- **AdyenComponents**: Individual payment method components (SEPA, iDEAL, BLIK, etc.)
- **AdyenActions**: Action handlers (redirects, vouchers, QR codes, 3DS challenges)
- **AdyenDropIn**: Complete payment flow orchestrator using MVVM-Router pattern
- **AdyenSession**: Simplified checkout flow managing `/sessions` endpoint integration
- **AdyenEncryption**: Client-side encryption for sensitive payment data
- **AdyenSwiftUI**: SwiftUI-specific helpers and utilities
- **AdyenCheckout**: Umbrella module combining all payment functionality
- **AdyenWeChatPay**, **AdyenCashAppPay**, **AdyenTwint**: Platform-specific payment methods

### Key Architectural Patterns

**Component Protocol System:**
All payment methods implement the `PaymentMethod` protocol and build corresponding components via `PaymentComponentBuilder`. Components communicate through delegates (`PaymentComponentDelegate`, `ActionComponentDelegate`).

**Drop-in Architecture:**
Uses MVVM-Router pattern with modular assemblies. The `DropInComponent` coordinates between `PaymentMethodListComponent`, individual payment components, and action handlers. Navigation is managed through `DropInRouter` and module-specific routers.

**Session Flow:**
`AdyenSession` wraps the simplified checkout flow, internally handling `/payments` and `/payment/details` calls. It acts as a delegate to components and provides feedback through `AdyenSessionDelegate`.

**Theming System:**
Centralized styling through `FormComponentStyle`, `ListComponentStyle`, etc. All visual components accept style parameters allowing full customization of colors, fonts, spacing, and corner radius.

**Form Architecture:**
Forms are built using `FormItem` types (text fields, buttons, pickers, toggles) managed by `FormViewController`. Each item has a corresponding view and validator. The form system is reactive, with items publishing value changes.

## Development Commands

### Building

Build the project:
```bash
xcodebuild -project Adyen.xcodeproj -scheme Adyen -configuration Debug build
```

### Testing

**List available simulators:**
```bash
xcrun simctl list devices available
```

**Run unit tests:**
```bash
# Option 1: Use a standard iPhone simulator (recommended)
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=iPhone 17'

# Option 2: Use specific device by ID (most reliable)
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,id=<DEVICE_ID>'
```

**Run integration tests:**
```bash
xcodebuild test -project Adyen.xcodeproj -scheme IntegrationUIKitTests -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Note:** Do not use `swift test` - it doesn't work well with the Xcode project structure. The `SnapshotTests` target is primarily for CI and not typically run during local development.

**Run single test:**
```bash
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:UnitTests/TestClassName/testMethodName
```

### Code Quality

**SwiftLint:**
```bash
swiftlint
```

**SwiftFormat (check):**
```bash
swiftformat --lint .
```

**SwiftFormat (apply):**
```bash
swiftformat .
```

## Demo App

Two demo apps are available in the `Demo/` directory:
- `Demo/UIKit/` - UIKit-based implementation examples
- `Demo/SwiftUI/` - SwiftUI-based implementation examples

Both demonstrate Drop-in and Components integration patterns.

## Code Style and Conventions

### Git Commit Messages

Follow this structure:
```
[purpose]: [Commit message: starts with verb, imperative mood]
```

**Purpose prefixes:**
- `feature` - public API increments
- `deprecate` - deprecated public API flagging
- `remove` - deprecated API removal
- `docs` - documentation changes
- `chore` - non-public API changes or refactoring
- `fix` - bug fixes

**Examples:**
```
chore: Update tests
feature: Add method xxx(aaa:bbb) to YYYY
fix: Resolve race condition in session handler
```

### Swift Style

- Line length: 140 characters (warning)
- File length: 500 lines (warning)
- Identifier min length: 2 characters
- SwiftFormat is configured with inline commas, no space ranges, and specific wrapping rules
- All files must include copyright header (auto-applied by SwiftFormat)

**IMPORTANT: Always run SwiftFormat after editing Swift files**

After making any code changes using editing tools, always run SwiftFormat to ensure compliance with the project's formatting rules:

```bash
# Format a single file
swiftformat path/to/edited/file.swift

# Format multiple files
swiftformat AdyenUI/UI/Form/Items/Text/
```

This prevents unintended whitespace changes and formatting inconsistencies that create noise in pull request diffs and increase reviewer burden.

### Access Control

Use `@_spi(AdyenInternal)` for internal-but-cross-module APIs. The SDK uses explicit access control levels (`explicit_acl` SwiftLint rule is enabled).

## Important Development Notes

### Module Dependencies

Modules have clear dependency chains:
- `AdyenUI` depends on `Adyen`
- `AdyenCard` depends on `Adyen`, `AdyenEncryption`, `AdyenUI`
- `AdyenDropIn` depends on `Adyen`, `AdyenCard`, `AdyenComponents`, `AdyenActions`
- `AdyenSession` depends on `Adyen`, `AdyenActions`

When modifying code, be mindful of these dependencies to avoid circular references.

### Library Evolution

The SDK is built with `BUILD_LIBRARY_FOR_DISTRIBUTION` enabled for binary compatibility. Protocol extensions must provide default implementations for this reason (see `PaymentMethod.buildComponent` for example).

### WeChat Pay and Twint

`AdyenWeChatPay` and `AdyenTwint` cannot run on simulators - they require physical devices for testing.

### Localization

Localization keys are generated automatically. After modifying `.strings` files, run:
```bash
swift Scripts/generate_localization_keys.swift
```

### Testing Philosophy

- Unit tests go in `Tests/UnitTests/`
- Integration tests go in `Tests/IntegrationTests/`
- Integration tests may use `XCTestCase+Wait` helpers for async operations
- Integration tests often create and present view controllers using `XCTestCase+RootViewController`
- Mock types follow the naming convention `*Mock` (e.g., `APIClientMock`, `PaymentComponentDelegateMock`)

## CI/CD

The project uses GitHub Actions for CI with the following key workflows:
- **verify-os-compatibility.yml**: Runs tests on multiple iOS versions (iOS 16, 17, 18)
- **pr_scan.yml**: Runs linting and validation on pull requests
- **test-SPM-integration.yml**: Validates Swift Package Manager integration
- **test_cocoapods_integration.yml**: Validates CocoaPods integration

## Resources

- [Public Documentation](https://docs.adyen.com/online-payments/build-your-integration/?platform=iOS)
- [API Reference](https://adyen.github.io/adyen-ios/5.20.0/documentation/adyen/)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Migration Guide](MIGRATION.md)
