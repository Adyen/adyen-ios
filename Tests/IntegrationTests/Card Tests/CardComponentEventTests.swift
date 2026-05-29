//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
final class CardComponentEventTests: XCTestCase {

    // EVT-UC9: Component Rendered - Send Initial Event
    func testViewDidLoadShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: CardConfiguration()
        )

        // When
        sut.viewDidLoad(viewController: sut.cardViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)

        let info = analyticsProviderMock.infos.first
        XCTAssertEqual(info?.type, .rendered)

        let configDataDict = try XCTUnwrap(info?.configData?.stringOnlyDictionary)
        XCTAssertEqual(configDataDict["socialSecurityNumberVisibility"], "auto")
        XCTAssertEqual(configDataDict["hasInstallmentOptions"], "false")
        XCTAssertEqual(configDataDict["billingAddressRequired"], "true")
        XCTAssertEqual(configDataDict["hideCVC"], "false")
        XCTAssertEqual(configDataDict["showCardholderName"], "false")
        XCTAssertEqual(configDataDict["showKCPType"], "auto")
        XCTAssertEqual(configDataDict["enableStoredDetails"], "true")
        XCTAssertEqual(configDataDict.keys.count, 7)
    }

    // MARK: - Focus/unfocus events

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_cardNumber_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let cardNumberItemView: FormTextItemView<FormCardNumberItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.FormCardNumberContainerItem.numberItem"
            )
        )

        testFocusEvents(
            for: cardNumberItemView,
            target: .cardNumber,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_expiryDate_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let expiryDateItemView: FormTextInputItemView = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        )

        testFocusEvents(
            for: expiryDateItemView,
            target: .expiryDate,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_securityCode_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let securityCodeItemView: FormCardSecurityCodeItemView = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        )

        testFocusEvents(
            for: securityCodeItemView,
            target: .securityCode,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_holderName_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.showCardholderName = true
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let holderNameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem")
        )

        testFocusEvents(
            for: holderNameItemView,
            target: .holderName,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_kcpField_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.koreanAuthenticationVisibility = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let kcpItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.CardComponent.additionalAuthCodeItem"
            )
        )

        testFocusEvents(
            for: kcpItemView,
            target: .taxNumber,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_kcpPassword_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.koreanAuthenticationVisibility = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let kcpPasswordItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.CardComponent.additionalAuthPasswordItem"
            )
        )

        testFocusEvents(
            for: kcpPasswordItemView,
            target: .authPassWord,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_socialSecurity_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.socialSecurityNumberVisibility = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let socialSecurityItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.CardComponent.socialSecurityNumberItem"
            )
        )

        testFocusEvents(
            for: socialSecurityItemView,
            target: .boletoSocialSecurityNumber,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    /// EVT-UC1, EVT-UC2: Field Focus/Unfocus - Send Focus and Unfocus Events
    func test_postalCode_onFocusAndUnfocus_shouldSendFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.billingAddress.mode = .postalCode
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let postalCodeItemView: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.postalCodeItem")
        )

        testFocusEvents(
            for: postalCodeItemView,
            target: .addressPostalCode,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // MARK: - Validation error events

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_cardNumber_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let cardNumberItemView: FormTextItemView<FormCardNumberItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.FormCardNumberContainerItem.numberItem"
            )
        )

        testValidationErrorEvent(
            for: cardNumberItemView,
            target: .cardNumber,
            invalidValue: "123",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.cardNumberPartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_expiryDate_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let expiryDateItemView: FormTextInputItemView = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        )

        testValidationErrorEvent(
            for: expiryDateItemView,
            target: .expiryDate,
            invalidValue: "13/20",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.expiryDatePartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_securityCode_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let securityCodeItemView: FormCardSecurityCodeItemView = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        )

        testValidationErrorEvent(
            for: securityCodeItemView,
            target: .securityCode,
            invalidValue: "12",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.securityCodePartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_holderName_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.showCardholderName = true
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let holderNameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem")
        )

        testValidationErrorEvent(
            for: holderNameItemView,
            target: .holderName,
            invalidValue: "",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.holderNameEmpty,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_kcpField_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.koreanAuthenticationVisibility = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let kcpItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.CardComponent.additionalAuthCodeItem"
            )
        )

        testValidationErrorEvent(
            for: kcpItemView,
            target: .taxNumber,
            invalidValue: "123",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.kcpFieldPartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_kcpPassword_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.koreanAuthenticationVisibility = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let kcpPasswordItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.CardComponent.additionalAuthPasswordItem"
            )
        )

        testValidationErrorEvent(
            for: kcpPasswordItemView,
            target: .authPassWord,
            invalidValue: "1",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.kcpPasswordPartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_socialSecurity_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.socialSecurityNumberVisibility = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let socialSecurityItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.CardComponent.socialSecurityNumberItem"
            )
        )

        testValidationErrorEvent(
            for: socialSecurityItemView,
            target: .boletoSocialSecurityNumber,
            invalidValue: "123",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.brazilSSNPartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC3: Explicit Validation Failure - Send Validation Error Event
    func test_postalCode_withInvalidValue_shouldSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardConfiguration()
        config.billingAddress.mode = .postalCode
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let postalCodeItemView: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.postalCodeItem")
        )

        testValidationErrorEvent(
            for: postalCodeItemView,
            target: .addressPostalCode,
            invalidValue: "1",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.postalCodePartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // MARK: - Focus loss with invalid input validation events

    // EVT-UC5: Focus Loss with Invalid Input - Send Both Unfocus and Validation Error Events
    func test_cardNumber_onFocusLossWithInvalidValue_shouldSendUnfocusAndValidationErrorEvents()
        throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let cardNumberItemView: FormTextItemView<FormCardNumberItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.FormCardNumberContainerItem.numberItem"
            )
        )

        testFocusLossValidationErrorEvent(
            for: cardNumberItemView,
            target: .cardNumber,
            invalidValue: "123",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.cardNumberPartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC5: Focus Loss with Invalid Input - Send Both Unfocus and Validation Error Events
    func test_expiryDate_onFocusLossWithInvalidValue_shouldSendUnfocusAndValidationErrorEvents()
        throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let expiryDateItemView: FormTextInputItemView = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem")
        )

        testFocusLossValidationErrorEvent(
            for: expiryDateItemView,
            target: .expiryDate,
            invalidValue: "1",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.expiryDatePartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC5: Focus Loss with Invalid Input - Send Both Unfocus and Validation Error Events
    func test_securityCode_onFocusLossWithInvalidValue_shouldSendUnfocusAndValidationErrorEvents()
        throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let securityCodeItemView: FormCardSecurityCodeItemView = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem")
        )

        testFocusLossValidationErrorEvent(
            for: securityCodeItemView,
            target: .securityCode,
            invalidValue: "1",
            expectedErrorCode: AnalyticsConstants.ValidationErrorCodes.securityCodePartial,
            analyticsProviderMock: analyticsProviderMock
        )
    }

    // EVT-UC4: Explicit Validation Success - No Validation Error Event
    func test_cardNumber_withValidValue_shouldNotSendValidationErrorEvent() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let cardNumberItemView: FormTextItemView<FormCardNumberItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(
                with: "AdyenCard.FormCardNumberContainerItem.numberItem"
            )
        )

        analyticsProviderMock.clearAll()

        cardNumberItemView.item.value = "5454545454545454"
        cardNumberItemView.showValidation()

        let validationErrorEvents = analyticsProviderMock.infos.filter {
            $0.type == .validationError
        }
        XCTAssertTrue(
            validationErrorEvents.isEmpty,
            "No validation error event should be sent when input is valid"
        )
    }

    // MARK: - Helper methods

    private func makeSUT(
        with configuration: CardConfiguration = .init(),
        analyticsProviderMock: AnalyticsProviderMock
    ) -> CardComponent {
        let context = Dummy.context(analyticsProvider: analyticsProviderMock)
        let cardComponent = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration
        )
        cardComponent.viewController.loadViewIfNeeded()

        return cardComponent
    }

    private func testFocusEvents(
        for field: FormTextItemView<some FormTextItem>,
        target: AnalyticsEventTarget,
        analyticsProviderMock: AnalyticsProviderMock
    ) {
        analyticsProviderMock.clearAll()

        field.textFieldDidBeginEditing(field.textField)
        field.textFieldDidEndEditing(field.textField)

        let firstInfoEvent = analyticsProviderMock.infos[0]
        let secondInfoEvent = analyticsProviderMock.infos[1]

        XCTAssertEqual(firstInfoEvent.type, .focus)
        XCTAssertEqual(firstInfoEvent.target, target)

        XCTAssertEqual(secondInfoEvent.type, .unfocus)
        XCTAssertEqual(secondInfoEvent.target, target)
    }

    private func testValidationErrorEvent(
        for field: FormTextItemView<some FormTextItem>,
        target: AnalyticsEventTarget,
        invalidValue: String,
        expectedErrorCode: Int,
        analyticsProviderMock: AnalyticsProviderMock
    ) {
        analyticsProviderMock.clearAll()

        field.item.value = invalidValue
        field.showValidation()

        XCTAssertEqual(
            analyticsProviderMock.infos.count, 1, "Expected exactly one validation error event"
        )

        let validationEvent = analyticsProviderMock.infos.first
        XCTAssertEqual(validationEvent?.type, .validationError)
        XCTAssertEqual(validationEvent?.target, target)
        XCTAssertEqual(
            validationEvent?.validationErrorCode,
            String(expectedErrorCode),
            "Expected error code \(expectedErrorCode) for \(target)"
        )
        XCTAssertNotNil(
            validationEvent?.validationErrorMessage, "Validation error should include error message"
        )
    }

    private func testFocusLossValidationErrorEvent(
        for field: FormTextItemView<some FormTextItem>,
        target: AnalyticsEventTarget,
        invalidValue: String,
        expectedErrorCode: Int,
        analyticsProviderMock: AnalyticsProviderMock
    ) {
        analyticsProviderMock.clearAll()

        field.item.value = invalidValue
        field.textFieldDidBeginEditing(field.textField)
        field.textFieldDidEndEditing(field.textField)

        XCTAssertEqual(
            analyticsProviderMock.infos.count,
            3,
            "Expected focus, unfocus, and validation error events"
        )

        let focusEvent = analyticsProviderMock.infos[0]
        XCTAssertEqual(focusEvent.type, .focus)
        XCTAssertEqual(focusEvent.target, target)

        let unfocusEvent = analyticsProviderMock.infos[1]
        XCTAssertEqual(unfocusEvent.type, .unfocus)
        XCTAssertEqual(unfocusEvent.target, target)

        let validationEvent = analyticsProviderMock.infos[2]
        XCTAssertEqual(validationEvent.type, .validationError)
        XCTAssertEqual(validationEvent.target, target)
        XCTAssertEqual(
            validationEvent.validationErrorCode,
            String(expectedErrorCode),
            "Expected error code \(expectedErrorCode) for \(target)"
        )
        XCTAssertNotNil(
            validationEvent.validationErrorMessage,
            "Validation error should include error message"
        )
    }

    private var method: CardPaymentMethod {
        .init(
            type: .card,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )
    }

}
