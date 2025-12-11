# Address Picker Redesign Plan (v6)

## Overview

Redesign of the address picker UI component for v6. Creates a generic reusable section header that adds title and subtitle to any form item, applied to the address picker with updated styling.

## Visual Structure

```
Billing address              (title - subtitle style)
Enter the billing address... (subtitle - subheadline style)

Address                      (label - bodyEmphasized style)
┌─────────────────────────────────────┐
│ [empty or address value]          > │  (rounded container + chevron)
└─────────────────────────────────────┘
Your billing address         (hint - subheadline style)

[Validation error replaces hint]
```

## Key Design Decisions

- **Empty container**: No placeholder inside container; hint shows below
- **Footer label**: Shows placeholder text OR validation error (not both)
- **Validation**: Red border on container + error message in footer

## Label Styles

| Element | Style |
|---------|-------|
| Section title ("Billing address") | `subtitle` |
| Section subtitle | `subheadline` |
| Field label ("Address") | `bodyEmphasized` |
| Footer hint/error | `subheadline` |

## Components

### FormSectionHeaderItem

**File**: `AdyenUI/UI/Form/Items/SectionHeader/FormSectionHeaderItem.swift`

Generic wrapper that adds title + subtitle to any FormItem. Uses `package` access level.

### FormSelectableValueItemView (Updated)

**File**: `AdyenUI/UI/Form/Items/Value/Selectable/FormSelectableValueItemView.swift`

- Added `containerView` with rounded corners and theme styling
- Added `footerLabel` for hint/validation messages
- Styling consolidated in `apply(_ theme:)` method

## Files Changed

| New | Modified |
|-----|----------|
| `FormSectionHeaderItem.swift` | `FormSelectableValueItemView.swift` |
| | `CardViewController.swift` |
| | `ACHDirectDebitComponent.swift` |
| | `AddressFormItemInjector.swift` |
| | `FormItemViewBuilder.swift` |
| | `AdyenUIConstants.swift` |

## Status

| Step | Status |
|------|--------|
| FormSectionHeaderItem + View | Done |
| FormSelectableValueItemView styling | Done |
| Card component | Done |
| ACH component | Done |
| AddressFormItemInjector | Done |
| Unit tests | Pending |
| Snapshots | Pending |

## Code Style

- Use `package` access (not `@_spi public`)
- No docc comments for package/internal members
- Use `AdyenUIConstants` for spacing
- Consolidate styling in `apply(_ theme:)` method
