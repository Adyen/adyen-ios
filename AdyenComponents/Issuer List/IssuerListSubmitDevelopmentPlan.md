# IssuerListComponent Submit Flow Development Plan

## Goal

Redesign `IssuerListComponent` so issuer selection and submission are separate actions.

The shopper should select an issuer first, then tap a submit button. If no issuer is selected, the component should show a validation error instead of submitting.

## Approach

Use a dedicated wrapper view controller owned by `IssuerListComponent`.

The wrapper should embed the existing `SearchViewController` and add issuer-specific UI below it:

- Validation view
- Submit button

This avoids modifying `SearchViewController` and keeps the new behavior specific to `IssuerListComponent`.

## Proposed Structure

```text
IssuerListComponent
└── IssuerListSubmitViewController
    ├── SearchViewController.view
    ├── Validation view
    └── Submit button
```

## Development Steps

- [ ] Create a wrapper view controller for `IssuerListComponent`.
- [ ] Embed the existing `SearchViewController` inside the wrapper.
- [ ] Add a validation view below the search/list content.
- [ ] Add a submit button below the validation view.
- [ ] Change issuer selection so it only updates `selectedIssuer` and selected UI state.
- [ ] Remove automatic submission from `ListItem.selectionHandler`.
- [ ] Implement validation based on whether `selectedIssuer` is set.
- [ ] Show the validation error when submitting without a selected issuer.
- [ ] Clear the validation error after a valid issuer selection.
- [ ] Update `submit()` so it validates first, then submits with the selected issuer.
- [ ] Wire the submit button tap to call `submit()`.
- [ ] Update loading behavior to match the new submit flow.
- [ ] Add or update tests for the new behavior.
- [ ] Run SwiftFormat on changed Swift files.

## Notes

- `SearchViewController` should remain unchanged.
- `ListSection.footer` is not suitable for this use case because it only supports a text footer and scrolls with the list.
- The wrapper may need keyboard handling if the submit button should stay visible above the keyboard.
- Loading may need to move from row-level loading to button-level loading, depending on the final design.
