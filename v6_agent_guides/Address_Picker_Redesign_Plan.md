# Address Picker Redesign Plan (v6)

## Overview

Redesign of the address picker UI component for v6. Creates a generic reusable section header that adds title and subtitle to any form item, applied to the address picker with updated styling.

## Visual Structure

```
Billing address              (title)
Enter the billing address... (subtitle)

Address                      (label)
┌─────────────────────────────────────┐
│ [empty or address value]          > │  (rounded container + chevron)
└─────────────────────────────────────┘
Your billing address         (hint)

[Validation error replaces hint]
```

## Key Design Decisions

- **Empty container**: No placeholder inside container; hint shows below
- **Footer label**: Shows placeholder text OR validation error (not both)
- **Validation**: Red border on container + error message in footer

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

| File | Change |
|------|--------|
| `AdyenUI/.../SectionHeader/FormSectionHeaderItem.swift` | NEW - Generic section header |
| `AdyenUI/.../Selectable/FormSelectableValueItemView.swift` | Container + footer label |
| `AdyenUI/UI/Form/FormItemViewBuilder.swift` | Pass theme to FormAddressPickerItemView |
| `AdyenUI/AdyenUIConstants.swift` | Added `minimumInputHeight` |
| `AdyenCard/.../CardViewController.swift` | Wrap picker with section header |
| `AdyenComponents/.../ACHDirectDebitComponent.swift` | Wrap picker with section header |
| `AdyenComponents/.../AddressFormItemInjector.swift` | Wrap picker with section header |

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

## Remaining Work

- Write tests for FormSectionHeaderItem
- Write tests for FormSelectableValueItemView styling
- Regenerate snapshots for Affirm, Atome, Boleto components

## Code Style

- Use `package` access (not `@_spi public`)
- No docc comments for package/internal members
- Use `AdyenUIConstants` for spacing
- Consolidate styling in `apply(_ theme:)` method
