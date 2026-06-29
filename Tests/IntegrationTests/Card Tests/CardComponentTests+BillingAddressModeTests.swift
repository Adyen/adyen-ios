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

/// Tests for `BillingAddressMode` configuration options including `hideForCardBrands`.
@MainActor
struct BillingAddressModeTests {

    // MARK: - .none mode

    @Test
    func none_noBillingAddressShown_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: BillingAddressMode.none,
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        #expect(proxy.isBillingAddressPickerVisible == false)

        proxy.fill(card: .visa)

        let submittedData = try await proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    // MARK: - hideForCardBrands Tests for .full mode

    @Test
    func full_hideForMatchingCard_hidesAddress_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: ["US"], hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        #expect(proxy.isBillingAddressPickerVisible == true)

        proxy.fill(card: .visa)
        await proxy.waitUntilBillingAddressPickerVisibility(is: false)

        let submittedData = try await proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func full_hideForNonMatchingCard_showsAddress_submitsAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: ["US"], hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa,
            shopperInformation: Self.shopperInformation
        )

        await proxy.load()
        proxy.fill(card: .visa)
        #expect(proxy.isBillingAddressPickerVisible == true)

        let submittedData = try await proxy.submitAndAwait()
        #expect(submittedData.billingAddress == Self.shopperInformation.billingAddress)
    }

    // MARK: - hideForCardBrands Tests for .postalCode mode

    @Test
    func postalCode_hideForMatchingCard_hidesPostalCode_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        #expect(proxy.isPostalCodeVisible == true)

        proxy.fill(card: .visa)
        await proxy.waitUntilPostalCodeVisibility(is: false)

        let submittedData = try await proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func postalCode_hideForNonMatchingCard_showsPostalCode_submitsPostalCode() async throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        proxy.fill(card: .visa)
        proxy.fillPostalCode("12345")
        #expect(proxy.isPostalCodeVisible == true)

        let submittedData = try await proxy.submitAndAwait()
        #expect(submittedData.billingAddress == PostalAddress(postalCode: "12345"))
    }

    // MARK: - hideForCardBrands Tests for .lookup mode

    @Test
    func lookup_hideForMatchingCard_hidesLookup_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .lookup(onAddressLookup: { _ in [] }, hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        #expect(proxy.isBillingAddressPickerVisible == true)

        proxy.fill(card: .visa)
        await proxy.waitUntilBillingAddressPickerVisibility(is: false)

        let submittedData = try await proxy.submitAndAwait()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func lookup_hideForNonMatchingCard_showsLookup_submitsAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .lookup(onAddressLookup: { _ in [] }, hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa,
            shopperInformation: Self.shopperInformation
        )

        await proxy.load()
        proxy.fill(card: .visa)
        #expect(proxy.isBillingAddressPickerVisible == true)

        let submittedData = try await proxy.submitAndAwait()
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

    func load() async {
        window.rootViewController = component.viewController
        window.makeKeyAndVisible()
        window.layer.speed = 10
        await yieldTasks(count: 10)
    }

    // MARK: - Readable State

    var isBillingAddressPickerVisible: Bool {
        component.cardViewController.items.billingAddressPickerItem?.isVisible ?? false
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

    func submitAndAwait(timeout: TimeInterval = 3) async throws -> PaymentComponentData {
        delegate.onDidFail = { _, _ in Issue.record("Should not fail") }

        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false

            delegate.onDidSubmit = { data, _ in
                guard !didResume else { return }
                didResume = true
                self.component.stopLoading()
                continuation.resume(returning: data)
            }

            tapSubmitButton()

            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                guard !didResume else { return }
                didResume = true
                continuation.resume(throwing: TimeoutError())
            }
        }
    }

    // MARK: - Waiting

    func waitUntilBillingAddressPickerVisibility(is expected: Bool, timeout: TimeInterval = 3) async {
        guard let item = component.cardViewController.items.billingAddressPickerItem else {
            Issue.record("billingAddressPickerItem is nil")
            return
        }
        await pollUntil({ item.isVisible == expected }, timeout: timeout)
    }

    func waitUntilPostalCodeVisibility(is expected: Bool, timeout: TimeInterval = 3) async {
        let item = component.cardViewController.items.postalCodeItem
        await pollUntil({ item.isVisible == expected }, timeout: timeout)
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

    private func yieldTasks(count: Int) async {
        for _ in 0..<count {
            await Task.yield()
        }
    }

    private func pollUntil(_ condition: @Sendable () -> Bool, timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            await yieldTasks(count: 10)
        }
        #expect(condition())
    }
}

private struct TimeoutError: Error {}
