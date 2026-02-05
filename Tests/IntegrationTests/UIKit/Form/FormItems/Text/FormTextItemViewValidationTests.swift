//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

/// Tests for form validation display behavior.
/// See FORM_VALIDATION_SPECS.md for use case definitions (UC1-UC4, UC11-UC13).
class FormTextItemViewValidationTests: XCTestCase {

    var item: FormTextInputItem!
    var validator: ValidatorMock!
    var sut: FormTextItemView<FormTextInputItem>!

    override func setUp() {
        super.setUp()
        item = FormTextInputItem()
        validator = ValidatorMock()
        item.validator = validator
        item.validationFailureMessage = "Invalid input"
        sut = FormTextItemView(item: item)
    }

    override func tearDown() {
        item = nil
        validator = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - UC1: Basic Text Field - Error on Explicit Validation

    /// UC1: GIVEN a text field with no placeholder AND invalid input
    /// WHEN the user taps the Pay button (explicit validation via showValidation)
    /// THEN the validation error message should appear
    func testUC1_ErrorOnExplicitValidation_ShowsErrorMessage() {
        // Given
        item.placeholder = nil
        validator.handleIsValid = { _ in false }
        sut.textField.text = "invalid"
        item.value = "invalid"

        // Verify error is not shown initially
        XCTAssertTrue(sut.footerLabel.isHidden, "Footer should be hidden initially")

        // When - explicit validation (simulates Pay button)
        sut.showValidation()

        // Then
        XCTAssertFalse(sut.footerLabel.isHidden, "Footer should be visible after validation")
        XCTAssertEqual(sut.footerLabel.text, "Invalid input")
        XCTAssertEqual(sut.footerLabel.textColor, sut.theme.colors.destructive)
    }

    /// UC1: GIVEN a text field with no placeholder AND invalid input
    /// WHEN explicit validation is triggered
    /// THEN the field border should turn red AND error accessory should appear
    func testUC1_ErrorOnExplicitValidation_ShowsErrorAccessoryAndBorder() {
        // Given
        item.placeholder = nil
        validator.handleIsValid = { _ in false }
        sut.textField.text = "invalid"
        item.value = "invalid"

        // When
        sut.showValidation()

        // Then
        XCTAssertEqual(sut.accessory, .invalid)
    }

    // MARK: - UC2: Basic Text Field - Error Cleared on Focus

    /// UC2: GIVEN a text field showing a validation error
    /// WHEN the user taps into the field
    /// THEN the validation error message should disappear (with animation)
    func testUC2_ErrorClearedOnFocus_HidesErrorMessage() {
        // Given - set up error state
        item.placeholder = nil
        validator.handleIsValid = { _ in false }
        sut.textField.text = "invalid"
        item.value = "invalid"
        sut.showValidation()
        XCTAssertFalse(sut.footerLabel.isHidden, "Precondition: error should be visible")

        // When - user taps into field (focus)
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then - wait for animation to complete
        wait(until: { sut.footerLabel.isHidden }, timeout: 1.0)
        XCTAssertTrue(sut.footerLabel.isHidden, "Footer should be hidden after gaining focus")
    }

    /// UC2: GIVEN a text field showing a validation error
    /// WHEN the user taps into the field
    /// THEN the error accessory should be removed AND border should return to active color
    func testUC2_ErrorClearedOnFocus_RemovesErrorAccessory() {
        // Given - set up error state
        validator.handleIsValid = { _ in false }
        sut.textField.text = "invalid"
        item.value = "invalid"
        sut.showValidation()
        XCTAssertEqual(sut.accessory, .invalid, "Precondition: invalid accessory should be shown")

        // When - user taps into field
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .none, "Accessory should be removed after gaining focus")
    }

    // MARK: - UC3: Basic Text Field - Error on Focus Loss

    /// UC3: GIVEN a text field with invalid input AND user was editing
    /// WHEN the user taps on another field (focus loss)
    /// THEN the validation error message should appear (with animation)
    func testUC3_ErrorOnFocusLoss_ShowsErrorMessage() {
        // Given
        item.placeholder = nil
        validator.handleIsValid = { _ in false }
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = "invalid"
        item.value = "invalid"

        // When - focus loss
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then - wait for animation to complete
        wait(until: { !sut.footerLabel.isHidden }, timeout: 1.0)
        XCTAssertFalse(
            sut.footerLabel.isHidden, "Footer should be visible after focus loss with invalid input"
        )
        XCTAssertEqual(sut.footerLabel.text, "Invalid input")
    }

    /// UC3: GIVEN a text field with invalid input
    /// WHEN focus is lost
    /// THEN the field border should turn red
    func testUC3_ErrorOnFocusLoss_ShowsErrorAccessory() {
        // Given
        validator.handleIsValid = { _ in false }
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = "invalid"
        item.value = "invalid"

        // When
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .invalid)
    }

    // MARK: - UC4: Basic Text Field - No Error While Typing

    /// UC4: GIVEN a text field with allowsValidationWhileEditing = false (default)
    /// WHEN the input becomes invalid during typing
    /// THEN NO validation error should be shown yet
    func testUC4_NoErrorWhileTyping() {
        // Given
        item.allowsValidationWhileEditing = false
        validator.handleIsValid = { _ in false }
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // When - user types invalid input
        sut.textField.text = "invalid"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(sut.footerLabel.isHidden, "Footer should remain hidden while typing")
        XCTAssertEqual(sut.accessory, .none, "No validation accessory while typing")
    }

    // MARK: - UC11: Field with Placeholder - Error Replaces Placeholder

    /// UC11: GIVEN a text field with a placeholder hint shown AND invalid input
    /// WHEN validation is triggered
    /// THEN the placeholder hint should be replaced with the error message
    func testUC11_ErrorReplacesPlaceholder() {
        // Given - create fresh item with placeholder
        let itemWithPlaceholder = FormTextInputItem()
        itemWithPlaceholder.placeholder = "Enter your code"
        itemWithPlaceholder.validationFailureMessage = "Invalid input"
        itemWithPlaceholder.validator = validator
        validator.handleIsValid = { _ in false }

        let sutWithPlaceholder = FormTextItemView(item: itemWithPlaceholder)

        // Verify placeholder is shown initially (before any input)
        XCTAssertFalse(sutWithPlaceholder.footerLabel.isHidden, "Footer should show placeholder")
        XCTAssertEqual(sutWithPlaceholder.footerLabel.text, "Enter your code")
        XCTAssertEqual(
            sutWithPlaceholder.footerLabel.textColor, sutWithPlaceholder.theme.colors.textSecondary
        )

        // Add invalid input
        sutWithPlaceholder.textField.text = "invalid"
        itemWithPlaceholder.value = "invalid"

        // When - explicit validation
        sutWithPlaceholder.showValidation()

        // Then - error replaces placeholder
        XCTAssertFalse(sutWithPlaceholder.footerLabel.isHidden)
        XCTAssertEqual(sutWithPlaceholder.footerLabel.text, "Invalid input")
        XCTAssertEqual(
            sutWithPlaceholder.footerLabel.textColor, sutWithPlaceholder.theme.colors.destructive
        )
    }

    // MARK: - UC12: Field with Placeholder - Placeholder Restored on Valid

    /// UC12: GIVEN a text field showing a validation error AND has a placeholder
    /// WHEN the user corrects the input to be valid AND validation is triggered
    /// THEN the error message should be replaced with the placeholder hint
    func testUC12_PlaceholderRestoredOnValid() {
        // Given - set up error state
        item.placeholder = "Enter your code"
        validator.handleIsValid = { _ in false }
        sut.textField.text = "invalid"
        item.value = "invalid"
        sut.showValidation()
        XCTAssertEqual(sut.footerLabel.text, "Invalid input", "Precondition: error should be shown")

        // When - user corrects input
        validator.handleIsValid = { _ in true }
        sut.textField.text = "valid"
        item.value = "valid"
        sut.showValidation()

        // Then
        XCTAssertFalse(sut.footerLabel.isHidden)
        XCTAssertEqual(sut.footerLabel.text, "Enter your code")
        XCTAssertEqual(sut.footerLabel.textColor, sut.theme.colors.textSecondary)
    }

    // MARK: - Edge Cases

    /// Edge case: Empty field should not show error on focus loss
    func testEmptyFieldNoErrorOnFocusLoss() {
        // Given
        validator.handleIsValid = { _ in false }
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = ""
        item.value = ""

        // When
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .none, "Empty field should not show validation accessory")
    }

    /// Edge case: Valid input should show valid accessory on focus loss
    func testValidInputShowsValidAccessoryOnFocusLoss() {
        // Given
        validator.handleIsValid = { _ in true }
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = "valid"
        item.value = "valid"

        // When
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then
        XCTAssertEqual(sut.accessory, .valid)
    }

    // MARK: - UC13: Animation - Footer Transitions

    /// UC13: Test that footer label transitions should be animated
    /// Note: This is a behavior documentation test - actual animation timing is hard to test
    func testUC13_FooterTransitionAnimation_ErrorAppears() {
        // Given - field with no error
        validator.handleIsValid = { _ in false }
        item.validationFailureMessage = "Invalid input"
        XCTAssertTrue(sut.footerLabel.isHidden, "Precondition: footer should be hidden initially")

        // When - validation triggered
        sut.showValidation()

        // Then - footer should appear with animation
        XCTAssertFalse(sut.footerLabel.isHidden, "Footer should appear (with animation)")
        XCTAssertEqual(sut.footerLabel.text, "Invalid input")
    }

    /// UC13: Test that footer transition animates when error clears
    func testUC13_FooterTransitionAnimation_ErrorClears() {
        // Given - field showing error
        validator.handleIsValid = { _ in false }
        item.validationFailureMessage = "Invalid input"
        sut.showValidation()
        XCTAssertFalse(sut.footerLabel.isHidden, "Precondition: footer should show error")

        // When - user focuses field (clears error)
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then - wait for animation to complete and verify footer hides
        wait(until: { sut.footerLabel.isHidden }, timeout: 1.0)
        XCTAssertTrue(sut.footerLabel.isHidden, "Footer should hide (with animation)")
    }

    // MARK: - Animation Behavior Tests

    /// Tests that footer visibility and alpha are set correctly when error appears
    func testAnimationBehavior_ErrorAppears_VisibilityAndAlphaCorrect() {
        // Given
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(true) }

        validator.handleIsValid = { _ in false }
        item.validationFailureMessage = "Invalid input"

        // When
        sut.showValidation()

        // Then - immediate state should be correct (animations disabled)
        XCTAssertFalse(sut.footerLabel.isHidden)
        XCTAssertEqual(sut.footerLabel.alpha, 1.0, accuracy: 0.01)
    }

    /// Tests that footer hides with animation when error clears
    func testAnimationBehavior_ErrorClears_VisibilityAndAlphaCorrect() {
        // Given - show error first
        validator.handleIsValid = { _ in false }
        item.validationFailureMessage = "Invalid input"
        sut.showValidation()
        XCTAssertFalse(sut.footerLabel.isHidden, "Precondition: error visible")

        // When - clear error by focusing
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Then - wait for animation to complete and verify final state
        wait(until: { sut.footerLabel.isHidden && sut.footerLabel.alpha == 0.0 }, timeout: 1.0)
        XCTAssertTrue(sut.footerLabel.isHidden)
        XCTAssertEqual(sut.footerLabel.alpha, 0.0, accuracy: 0.01)
    }

    /// Tests that placeholder-to-error transition sets correct text and color
    func testAnimationBehavior_PlaceholderToError_TextAndColorCorrect() {
        // Given - field with placeholder
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(true) }

        let itemWithPlaceholder = FormTextInputItem()
        itemWithPlaceholder.placeholder = "Enter code"
        itemWithPlaceholder.validationFailureMessage = "Invalid"
        itemWithPlaceholder.validator = validator
        validator.handleIsValid = { _ in false }

        let sutWithPlaceholder = FormTextItemView(item: itemWithPlaceholder)

        // Verify placeholder is shown
        XCTAssertEqual(sutWithPlaceholder.footerLabel.text, "Enter code")
        XCTAssertEqual(
            sutWithPlaceholder.footerLabel.textColor, sutWithPlaceholder.theme.colors.textSecondary
        )

        // When - trigger validation
        sutWithPlaceholder.showValidation()

        // Then - error replaces placeholder with correct styling
        XCTAssertEqual(sutWithPlaceholder.footerLabel.text, "Invalid")
        XCTAssertEqual(
            sutWithPlaceholder.footerLabel.textColor, sutWithPlaceholder.theme.colors.destructive
        )
    }

    /// Tests that error-to-placeholder transition restores correct text and color
    func testAnimationBehavior_ErrorToPlaceholder_TextAndColorCorrect() {
        // Given - field showing error with placeholder defined
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(true) }

        item.placeholder = "Enter code"
        validator.handleIsValid = { _ in false }
        item.validationFailureMessage = "Invalid"
        sut.showValidation()

        XCTAssertEqual(sut.footerLabel.text, "Invalid")
        XCTAssertEqual(sut.footerLabel.textColor, sut.theme.colors.destructive)

        // When - clear error and make valid
        validator.handleIsValid = { _ in true }
        sut.showValidation()

        // Then - placeholder restored with correct styling
        XCTAssertEqual(sut.footerLabel.text, "Enter code")
        XCTAssertEqual(sut.footerLabel.textColor, sut.theme.colors.textSecondary)
    }

    /// Tests that footer state is synchronously accessible after validation (for tests)
    func testAnimationBehavior_StateIsSynchronouslyAccessible() {
        // Given
        validator.handleIsValid = { _ in false }
        item.validationFailureMessage = "Error"

        // When - trigger validation (with animations enabled)
        sut.showValidation()

        // Then - state should be immediately readable (isHidden set synchronously)
        XCTAssertFalse(sut.footerLabel.isHidden, "isHidden should be set synchronously")
        XCTAssertEqual(sut.footerLabel.text, "Error", "Text should be set synchronously")
    }

    // MARK: - UI Synchronization Tests

    /// Tests that ALL validation UI components (accessory, border, footer) are synchronized
    /// when validation is triggered on focus loss for non-empty invalid input.
    func testIssue1_FocusLoss_AllValidationUIComponentsSync() {
        // Given - invalid input in focused field
        item.value = "abc"
        validator.handleIsValid = { _ in false }
        item.validationFailureMessage = "Invalid input"
        sut.textField.text = "abc"
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // Preconditions
        XCTAssertTrue(sut.isEditing)
        XCTAssertEqual(sut.accessory, .none)
        XCTAssertTrue(sut.footerLabel.isHidden)

        // When - field loses focus (triggers validation for non-empty field)
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)

        // Then - wait for animation and verify ALL validation UI components show error state
        wait(until: { !sut.footerLabel.isHidden }, timeout: 1.0)
        XCTAssertEqual(sut.accessory, .invalid)
        XCTAssertFalse(sut.footerLabel.isHidden, "Footer should show error message")
        XCTAssertEqual(sut.footerLabel.text, "Invalid input")
        XCTAssertTrue(sut.isShowingValidationError)
    }
}
