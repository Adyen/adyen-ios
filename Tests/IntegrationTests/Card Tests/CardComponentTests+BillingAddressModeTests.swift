//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

/// Tests for `BillingAddressMode` configuration options including `hideForCardTypes`.
extension CardComponentTests {

    // MARK: - hideForCardTypes Tests for .full mode

    func test_full_withHideForCardTypes_shouldHideAddressWhenMatchingCardDetected() throws {
        var configuration = CardConfiguration()
        configuration.billingAddressMode = .full(supportedCountryCodes: ["US"], hideForCardTypes: [.visa])

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let billingAddressItem = sut.cardViewController.items.billingAddressPickerItem

        // Initially visible
        XCTAssertTrue(billingAddressItem?.isVisible == true)

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        // After entering Visa card number, billing address should be hidden
        try wait(until: XCTUnwrap(billingAddressItem), at: \.isVisible, is: false)

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            // No billing address should be included since it was hidden
            XCTAssertNil(data.billingAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_full_withHideForCardTypes_shouldShowAddressWhenNonMatchingCardDetected() throws {
        var configuration = CardConfiguration()
        configuration.billingAddressMode = .full(supportedCountryCodes: ["US"], hideForCardTypes: [.jcb])
        configuration.shopperInformation = shopperInformation

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let billingAddressItem = sut.cardViewController.items.billingAddressPickerItem

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        // Billing address should remain visible for Visa (not in hideForCardTypes)
        XCTAssertTrue(billingAddressItem?.isVisible == true)

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertEqual(data.billingAddress, self.shopperInformation.billingAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    // MARK: - hideForCardTypes Tests for .postalCode mode

    func test_postalCode_withHideForCardTypes_shouldHidePostalCodeWhenMatchingCardDetected() throws {
        var configuration = CardConfiguration()
        configuration.billingAddressMode = .postalCode(hideForCardTypes: [.visa])

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let postalCodeItem = sut.cardViewController.items.postalCodeItem

        // Initially visible
        XCTAssertTrue(postalCodeItem.isVisible)

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        // After entering Visa card number, postal code should be hidden
        wait(until: postalCodeItem, at: \.isVisible, is: false)

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            // No billing address should be included since postal code was hidden
            XCTAssertNil(data.billingAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_postalCode_withHideForCardTypes_shouldShowPostalCodeWhenNonMatchingCardDetected() throws {
        var configuration = CardConfiguration()
        configuration.billingAddressMode = .postalCode(hideForCardTypes: [.jcb])

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let postalCodeField: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(view.findView(by: CardViewIdentifier.zipCode))
        let postalCodeItem = sut.cardViewController.items.postalCodeItem

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")
        populate(textItemView: postalCodeField, with: "12345")

        // Postal code should remain visible for Visa (not in hideForCardTypes)
        XCTAssertTrue(postalCodeItem.isVisible)

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertEqual(data.billingAddress, PostalAddress(postalCode: "12345"))

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    // MARK: - hideForCardTypes Tests for .lookup mode

    func test_lookup_withHideForCardTypes_shouldHideLookupWhenMatchingCardDetected() throws {
        var configuration = CardConfiguration()
        configuration.billingAddressMode = .lookup(
            onAddressLookup: { _ in [] },
            hideForCardTypes: [.visa]
        )

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let billingAddressItem = sut.cardViewController.items.billingAddressPickerItem

        // Initially visible
        XCTAssertTrue(billingAddressItem?.isVisible == true)

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        // After entering Visa card number, billing address lookup should be hidden
        try wait(until: XCTUnwrap(billingAddressItem), at: \.isVisible, is: false)

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            // No billing address should be included since lookup was hidden
            XCTAssertNil(data.billingAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func test_lookup_withHideForCardTypes_shouldShowLookupWhenNonMatchingCardDetected() throws {
        var configuration = CardConfiguration()
        configuration.billingAddressMode = .lookup(
            onAddressLookup: { _ in [] },
            hideForCardTypes: [.jcb]
        )
        configuration.shopperInformation = shopperInformation

        let cardTypeProviderMock = BinInfoProviderMock()
        cardTypeProviderMock.onFetch = {
            $0(BinLookupResponse(
                brands: [CardBrand(type: .visa)],
                issuingCountryCode: "US"
            ))
        }

        let sut = CardComponent(
            paymentMethod: method,
            context: context,
            configuration: configuration,
            binProvider: cardTypeProviderMock
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        setupRootViewController(sut.viewController)

        let view: UIView = sut.cardViewController.view

        let securityCodeField: FormCardSecurityCodeItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.securityCode))
        let expiryDateField: FormTextInputItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.expiryDate))
        let numberField: FormCardNumberItemView = try XCTUnwrap(view.findView(by: CardViewIdentifier.cardNumber))
        let billingAddressItem = sut.cardViewController.items.billingAddressPickerItem

        populate(textItemView: securityCodeField, with: "737")
        populate(textItemView: numberField, with: "4111 1120 1426 7661")
        populate(textItemView: expiryDateField, with: "12/30")

        // Billing address lookup should remain visible for Visa (not in hideForCardTypes)
        XCTAssertTrue(billingAddressItem?.isVisible == true)

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidFail = { error, component in XCTFail("should not fail") }
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is CardDetails)

            XCTAssertEqual(data.billingAddress, self.shopperInformation.billingAddress)

            sut.stopLoading()
            delegateExpectation.fulfill()
        }

        tapSubmitButton(on: sut.viewController.view)

        waitForExpectations(timeout: 10, handler: nil)
    }
}
