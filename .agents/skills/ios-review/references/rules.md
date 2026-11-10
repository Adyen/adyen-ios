# iOS review rules

Checks specific to the Adyen iOS SDK v6. Apply the sections the change touches. Each rule names its source; "Team convention" marks rules that come from review history rather than a document.

## Public API

- New `public` or `open` declarations are necessary. Prefer `package`; making something public later is easy, making it internal again is a breaking change. ([AGENTS.md: Access Control](../../../../AGENTS.md#access-control))
- New cross-module internal code uses `package`, not `@_spi(AdyenInternal)`. The exception is when Swift requires `public`, such as `init(from:)` on a public `Decodable` type. ([AGENTS.md: Access Control](../../../../AGENTS.md#access-control))
- A public API change updates `MIGRATION.md` in the same change. ([AGENTS.md: Important Development Notes](../../../../AGENTS.md#important-development-notes))
- New requirements on public protocols have default implementations. `package` protocols are exempt. ([AGENTS.md: Library Evolution](../../../../AGENTS.md#library-evolution))
- Component configurations follow the v6 shape: a standalone public type without "Component" in its name, non-public properties, a `public init` with only the values that have no default, and public builder methods. ([AGENTS.md: v6 Public API Conventions](../../../../AGENTS.md#v6-public-api-conventions))
- A public type whose set of values can grow is a `RawRepresentable` struct, not an enum. ([AGENTS.md: v6 Public API Conventions](../../../../AGENTS.md#v6-public-api-conventions))
- Public names are specific enough not to clash with merchant code; generic ones get a `Checkout` prefix. ([AGENTS.md: v6 Public API Conventions](../../../../AGENTS.md#v6-public-api-conventions))
- Public docs match the signature and behavior: optionality, parameters, return value, and examples that compile. They are concise and do not use the word "merchant". The word rule applies to public DocC only, not to tests or internal comments. ([AGENTS.md: v6 Public API Conventions](../../../../AGENTS.md#v6-public-api-conventions))
- Localization keys are public only when merchants should be able to override them. (Team convention)
- Removing or renaming a public localization key is a public API change, including the `MIGRATION.md` entry. (Team convention)

## Modules

- Imports follow the dependency chain. A feature module does not import a sibling feature module, for example `AdyenCard` must not import `AdyenComponents`; shared code moves to `AdyenUI` or `Adyen`. ([AGENTS.md: Module Dependencies](../../../../AGENTS.md#module-dependencies))
- A new `UIKit` import in non-UI code, such as core or orchestration code, needs a reason. (Team convention)
- New code does not add `@_spi` imports, except to use a symbol that is still `@_spi` and cannot become `package` in this change. (Team convention)

## UI

- No magic numbers. Layout values live in a `private enum Constants` or `Layout` in the same file. ([AGENTS.md: UI Code](../../../../AGENTS.md#ui-code))
- Accessibility identifiers are built with `ViewIdentifierBuilder`. ([AGENTS.md: UI Code](../../../../AGENTS.md#ui-code))
- SDK modules contain no SwiftUI previews (`#Preview` or `PreviewProvider`), even behind `#if DEBUG`. ([AGENTS.md: UI Code](../../../../AGENTS.md#ui-code))
- A view displays state it receives from its item or view model; it does not decide priority between booleans, such as error before hint. (Team convention)
- When only one of several elements can be visible at a time, an exclusive state enum drives them. (Team convention)
- SwiftUI hosted in UIKit uses `UIHostingConfiguration` for a view, or full child view controller containment (`addChild`, `didMove(toParent:)`) for a hosting controller. (Team convention)
- A UI change is checked on the screen sizes and orientations it affects. In PR mode, a UI change without a demo in the PR description gets a Question. ([PR template](../../../../.github/PULL_REQUEST_TEMPLATE.md))

## Behavior

- Analytics events still fire once, on the same trigger, after the change. New screens and components are tracked. (Team convention)
- UI that switches from a translated string to a new key that only exists in `en-US` shows English to every other locale. Ask whether translations arrive before release, unless the description says so. (Team convention)
- `PaymentComponent.submit(data:)` already runs `prepareSubmitData` before calling `didSubmit`. Code that receives `didSubmit` must not prepare the data again. (Team convention)
- Values that later calls depend on, such as a session ID or result, are never replaced with placeholders like `""`. Guard and report instead. (Team convention)
- A change to a shared concern, such as the store payment method toggle or zero-amount handling, is applied to every component that has it, for example Card, ACH Direct Debit, and Cash App Pay. Find them with a search rather than from memory. (Team convention)

## Concurrency

- Use the async version of an API when one exists, instead of wrapping its callback in a continuation. (Team convention)
- A `Task` with no `await` inside, used only to reach the main actor, points to missing `@MainActor` isolation. (Team convention)
- A stored `Task` property needs a real use, such as cancellation that matters. (Team convention)

## Tests

- Tests live in the right folder (unit or integration). New tests follow the naming convention even when older tests in the same file do not. Swift Testing `@Test` functions use the same structure without the `test_` prefix. ([TESTING.md: Test Naming Convention](../../../../TESTING.md#test-naming-convention), [Swift Testing](../../../../TESTING.md#swift-testing))
- New behavior has tests that would fail if it broke. Similar tests in other files are updated too. (Team convention)
- Test inputs are clearly distinct from each other, so a reader can tell the cases apart. (Team convention)
- During migrations, tests verify behavior rather than API surface details. ([TESTING.md: When to Avoid Unit Tests](../../../../TESTING.md#when-to-avoid-unit-tests))

## Demo app

- An example shows only what it demonstrates. Setup that v6 no longer needs, and callbacks that do not apply to the component (such as `.onAction` for Apple Pay), are removed. (Team convention)
- New examples do not duplicate an existing example with small changes. (Team convention)

## Noise and leftovers

- Commented-out code, unused imports, properties, or functions, and TODOs that are already done.
- Copyright header changes on existing files. SwiftFormat sometimes rewrites the year.
- Unexpected `Adyen.xcodeproj/project.pbxproj` changes, such as duplicate entries, null references, or unrelated entries.
- Manual reformatting of lines the change does not otherwise touch. Do not flag formatting that SwiftFormat enforces.
- Comments that narrate the code, and `///` doc comments used for plain comments.
- Generated files, such as localization keys from `Scripts/generate_localization_keys.swift`: check they were regenerated from their source change rather than edited by hand. Do not review them line by line. ([AGENTS.md: Localization](../../../../AGENTS.md#localization))
