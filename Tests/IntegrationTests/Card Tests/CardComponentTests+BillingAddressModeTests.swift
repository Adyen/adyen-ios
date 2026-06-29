//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit
import XCTest

/// Tests for `BillingAddressMode` configuration options including `hideForCardBrands`.
@MainActor
struct BillingAddressModeTests {

    // MARK: - .none mode

    @Test
    func none_noBillingAddressShown_submitsNilBillingAddress() throws {
        let proxy = makeSUT(
            billingAddressMode: BillingAddressMode.none,
            detectedBrand: CardBrand.visa
        )

        proxy.load()
        #expect(proxy.isBillingAddressPickerVisible == nil)

        proxy.fill(card: .visa)

        let submittedData = try proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    // MARK: - hideForCardBrands Tests for .full mode

    @Test
    func full_hideForMatchingCard_hidesAddress_submitsNilBillingAddress() throws {
        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: ["US"], hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        proxy.load()
        #expect(proxy.isBillingAddressPickerVisible == true)

        proxy.fill(card: .visa)
        proxy.waitUntilBillingAddressPickerVisibility(is: false)

        let submittedData = try proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func full_hideForNonMatchingCard_showsAddress_submitsAddress() throws {
        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: ["US"], hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa,
            shopperInformation: Self.shopperInformation
        )

        proxy.load()
        proxy.fill(card: .visa)
        #expect(proxy.isBillingAddressPickerVisible == true)

        let submittedData = try proxy.submitAndAwait()
        #expect(submittedData.billingAddress == Self.shopperInformation.billingAddress)
    }

    // MARK: - hideForCardBrands Tests for .postalCode mode

    @Test
    func postalCode_hideForMatchingCard_hidesPostalCode_submitsNilBillingAddress() throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        proxy.load()
        #expect(proxy.isPostalCodeVisible == true)

        proxy.fill(card: .visa)
        proxy.waitUntilPostalCodeVisibility(is: false)

        let submittedData = try proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func postalCode_hideForNonMatchingCard_showsPostalCode_submitsPostalCode() throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa
        )

        proxy.load()
        proxy.fill(card: .visa)
        proxy.fillPostalCode("12345")
        #expect(proxy.isPostalCodeVisible == true)

        let submittedData = try proxy.submitAndAwait()
        #expect(submittedData.billingAddress == PostalAddress(postalCode: "12345"))
    }

    // MARK: - hideForCardBrands Tests for .lookup mode

    @Test
    func lookup_hideForMatchingCard_hidesLookup_submitsNilBillingAddress() throws {
        let proxy = makeSUT(
            billingAddressMode: .lookup(onAddressLookup: { _ in [] }, hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        proxy.load()
        #expect(proxy.isBillingAddressPickerVisible == true)

        proxy.fill(card: .visa)
        proxy.waitUntilBillingAddressPickerVisibility(is: false)

        let submittedData = try proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func lookup_hideForNonMatchingCard_showsLookup_submitsAddress() throws {
        let proxy = makeSUT(
            billingAddressMode: .lookup(onAddressLookup: { _ in [] }, hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa,
            shopperInformation: Self.shopperInformation
        )

        proxy.load()
        proxy.fill(card: .visa)
        #expect(proxy.isBillingAddressPickerVisible == true)

        let submittedData = try proxy.submitAndAwait()
        #expect(submittedData.billingAddress == Self.shopperInformation.billingAddress)
    }

    // MARK: - Helpers

    private static var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        return .init(
            shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
            emailAddress: "katrina@mail.com",
            phoneNumber: .init(value: "1234567890", callingCode: "+1"),
            billingAddress: billingAddress,
            deliveryAddress: deliveryAddress,
            socialSecurityNumber: "78542134370",
            card: .init(holderName: "Katrina del Mar")
        )
    }

    private func makeSUT(
        billingAddressMode: BillingAddressMode,
        detectedBrand: CardBrand,
        shopperInformation: PrefilledShopperInformation? = nil
    ) -> BillingAddressModeProxy {
        var proxy: BillingAddressModeProxy!
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            var configuration = CardConfiguration()
            configuration.billingAddressMode = billingAddressMode
            if let shopperInformation {
                configuration.shopperInformation = shopperInformation
            }

            let binProvider = BinInfoProviderMock()
            binProvider.onFetch = {
                $0(BinLookupResponse(
                    brands: [DetectedCardBrand(brand: detectedBrand)],
                    issuingCountryCode: "US"
                ))
            }

            let method = CardPaymentMethod(
                type: .bcmc,
                name: "Test name",
                fundingSource: .credit,
                brands: [.visa, .americanExpress, .masterCard]
            )

            let component = CardComponent(
                paymentMethod: method,
                context: Dummy.context,
                configuration: configuration,
                binProvider: binProvider
            )

            proxy = BillingAddressModeProxy(component: component)
        }
        return proxy
    }
}

// MARK: - BillingAddressModeProxy

@MainActor
private struct BillingAddressModeProxy {

    let component: CardComponent

    private let delegate = PaymentComponentDelegateMock()
    private let window = UIWindow(frame: UIScreen.main.bounds)

    init(component: CardComponent) {
        self.component = component
        component.delegate = delegate
    }

    // MARK: - Card Input Data

    enum CardInput {
        case visa

        var number: String {
            switch self {
            case .visa: "4111 1120 1426 7661"
            }
        }

        var expiryDate: String {
            "12/30"
        }

        var securityCode: String {
            "737"
        }
    }

    // MARK: - Lifecycle

    func load() {
        window.rootViewController = component.viewController
        window.makeKeyAndVisible()
        window.layer.speed = 10
        waitForDuration(.milliseconds(100))
    }

    // MARK: - Readable State

    var isBillingAddressPickerVisible: Bool? {
        component.cardViewController.items.billingAddressPickerItem?.isVisible
    }

    var isPostalCodeVisible: Bool {
        component.cardViewController.items.postalCodeItem.isVisible
    }

    // MARK: - User Actions

    func fill(card: CardInput) {
        let view = component.cardViewController.view!
        let securityCodeField: FormCardSecurityCodeItemView? = view.findView(by: "AdyenCard.CardComponent.securityCodeItem")
        let expiryDateField: FormTextInputItemView? = view.findView(by: "AdyenCard.CardComponent.expiryDateItem")
        let numberField: FormCardNumberItemView? = view.findView(by: "AdyenCard.FormCardNumberContainerItem.numberItem")

        populate(securityCodeField, with: card.securityCode)
        populate(numberField, with: card.number)
        populate(expiryDateField, with: card.expiryDate)
    }

    func fillPostalCode(_ value: String) {
        let view = component.cardViewController.view!
        let postalCodeField: FormTextItemView<FormPostalCodeItem>? = view.findView(by: "AdyenCard.CardComponent.postalCodeItem")
        populate(postalCodeField, with: value)
    }

    func submitAndAwait(timeout: TimeInterval = 10) throws -> PaymentComponentData {
        let submitExpectation = XCTestExpectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        var submittedData: PaymentComponentData?

        delegate.onDidFail = { _, _ in Issue.record("Should not fail") }
        delegate.onDidSubmit = { data, _ in
            submittedData = data
            self.component.stopLoading()
            submitExpectation.fulfill()
        }

        tapSubmitButton()

        let waiter = XCTWaiter()
        let result = waiter.wait(for: [submitExpectation], timeout: timeout)
        if result != .completed {
            Issue.record("Submit expectation was not fulfilled within \(timeout)s")
        }

        return try #require(submittedData, "Expected submitted data but none was received")
    }

    // MARK: - Waiting

    func waitUntilBillingAddressPickerVisibility(is expected: Bool, timeout: TimeInterval = 60) {
        guard let item = component.cardViewController.items.billingAddressPickerItem else {
            Issue.record("billingAddressPickerItem is nil")
            return
        }
        pollUntil({ item.isVisible == expected }, timeout: timeout)
    }

    func waitUntilPostalCodeVisibility(is expected: Bool, timeout: TimeInterval = 60) {
        let item = component.cardViewController.items.postalCodeItem
        pollUntil({ item.isVisible == expected }, timeout: timeout)
    }

    // MARK: - Private Helpers

    private func populate(_ itemView: (some FormTextItemView<some FormTextItem>)?, with text: String) {
        guard let itemView else { return }
        itemView.textField.text = text
        itemView.textField.sendActions(for: .editingChanged)
    }

    private func tapSubmitButton() {
        let payButton: UIControl? = component.viewController.view.findView(
            with: "AdyenCard.CardComponent.payButtonItem.button"
        )
        payButton?.sendActions(for: .touchUpInside)
    }

    private func waitForDuration(_ interval: DispatchTimeInterval) {
        let exp = XCTestExpectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { exp.fulfill() }
        XCTWaiter().wait(for: [exp], timeout: 10)
    }

    private func pollUntil(_ condition: () -> Bool, timeout: TimeInterval) {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            waitForDuration(.seconds(1))
        }
        #expect(condition())
    }
}
