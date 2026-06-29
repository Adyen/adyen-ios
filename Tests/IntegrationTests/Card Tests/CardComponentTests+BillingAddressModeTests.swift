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

/// Tests for `BillingAddressMode` configuration options.
@MainActor
struct BillingAddressModeTests {

    // MARK: - Arbitrary test values (do not influence outcomes)

    private static let anySupportedCountryCodes = ["US"]
    private static let anyCardBrand = CardBrand.visa
    private static let anyHideForCardBrands: Set<CardBrand> = []
    private static let anyOnAddressLookup: (String) async -> [AddressLookupResult] = { _ in [] }

    // MARK: - .none

    @Test
    func none_noBillingAddressShown_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: BillingAddressMode.none
        )

        await proxy.load()
        await proxy.expectBillingAddressPickerVisible(false)

        proxy.fillCardDetails()

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == nil)
    }

    // MARK: - .full

    @Test
    func full_hideForMatchingCard_hidesAddress_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: Self.anySupportedCountryCodes, hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        await proxy.expectBillingAddressPickerVisible(true)

        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(false)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func full_hideForNonMatchingCard_showsAddress_submitsAddress() async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: Self.anySupportedCountryCodes, hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.fillBillingAddressViaForm(with: expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test(arguments: [CardBrand.visa, .masterCard, .americanExpress, .jcb, .discover, .maestro])
    func full_hideForEmptyBrands_neverHides(detectedBrand: CardBrand) async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: Self.anySupportedCountryCodes, hideForCardBrands: []),
            detectedBrand: detectedBrand
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.fillBillingAddressViaForm(with: expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test(arguments: [CardBrand.visa, .masterCard])
    func full_hideForMultipleBrands_hidesForAnyMatch(detectedBrand: CardBrand) async throws {
        let proxy = makeSUT(
            billingAddressMode: .full(
                supportedCountryCodes: Self.anySupportedCountryCodes,
                hideForCardBrands: [CardBrand.visa, CardBrand.masterCard]
            ),
            detectedBrand: detectedBrand
        )

        await proxy.load()
        await proxy.expectBillingAddressPickerVisible(true)

        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(false)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func full_supportedCountryCodes_filtersCountryList() async throws {
        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: ["US", "NL"], hideForCardBrands: Self.anyHideForCardBrands)
        )

        await proxy.load()
        proxy.fillCardDetails()
        try await proxy.expectAddressFormCountryPicker(containsExactly: ["US", "NL"])
    }

    @Test
    func full_emptySupportedCountryCodes_showsAllCountries() async throws {
        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: [], hideForCardBrands: Self.anyHideForCardBrands)
        )

        await proxy.load()
        proxy.fillCardDetails()
        try await proxy.expectAddressFormCountryPicker(containsAtLeast: ["US", "NL", "GB"])
    }

    @Test
    func full_singleSupportedCountryCode_showsOnlyThatCountry() async throws {
        let expectedAddress = PostalAddress(
            city: "London", country: "GB", houseNumberOrName: "10",
            postalCode: "SW1A 1AA", street: "Downing Street"
        )

        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: ["GB"], hideForCardBrands: Self.anyHideForCardBrands)
        )

        await proxy.load()
        proxy.fillCardDetails()
        try await proxy.expectAddressFormCountryPicker(containsExactly: ["GB"], selectedCountry: "GB")

        try await proxy.fillBillingAddressViaForm(with: expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test
    func full_submitWithoutAddress_showsValidationError_thenSucceedsAfterFilling() async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: Self.anySupportedCountryCodes, hideForCardBrands: Self.anyHideForCardBrands)
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.expectBillingAddressShowsValidationError()

        try await proxy.fillBillingAddressViaForm(with: expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    // MARK: - .postalCode

    @Test
    func postalCode_hideForMatchingCard_hidesPostalCode_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        await proxy.expectPostalCodeVisible(true)

        proxy.fillCardDetails()
        await proxy.expectPostalCodeVisible(false)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func postalCode_hideForNonMatchingCard_showsPostalCode_submitsPostalCode() async throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: [CardBrand.jcb]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        proxy.fillCardDetails()
        proxy.fillPostalCode("12345")
        await proxy.expectPostalCodeVisible(true)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == PostalAddress(postalCode: "12345"))
    }

    @Test(arguments: [CardBrand.visa, .masterCard, .americanExpress, .jcb, .discover, .maestro])
    func postalCode_hideForEmptyBrands_neverHides(detectedBrand: CardBrand) async throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: []),
            detectedBrand: detectedBrand
        )

        await proxy.load()
        proxy.fillCardDetails()
        proxy.fillPostalCode("12345")
        await proxy.expectPostalCodeVisible(true)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == PostalAddress(postalCode: "12345"))
    }

    // MARK: - .lookup

    @Test
    func lookup_hideForMatchingCard_hidesLookup_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .lookup(onAddressLookup: Self.anyOnAddressLookup, hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        await proxy.expectBillingAddressPickerVisible(true)

        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(false)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == nil)
    }

    @Test
    func lookup_hideForNonMatchingCard_showsLookup_submitsAddress() async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress },
                hideForCardBrands: [CardBrand.jcb]
            ),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.fillBillingAddressViaLookup(expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test(arguments: [CardBrand.visa, .masterCard, .americanExpress, .jcb, .discover, .maestro])
    func lookup_hideForEmptyBrands_neverHides(detectedBrand: CardBrand) async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress },
                hideForCardBrands: Self.anyHideForCardBrands
            ),
            detectedBrand: detectedBrand
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.fillBillingAddressViaLookup(expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test
    func lookup_onAddressLookup_isCalled() async throws {
        var receivedSearchTerms: [String] = []

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                onAddressLookup: { searchTerm in
                    receivedSearchTerms.append(searchTerm)
                    return []
                },
                hideForCardBrands: Self.anyHideForCardBrands
            )
        )

        await proxy.load()
        proxy.fillCardDetails()

        _ = try await proxy.openBillingAddressLookup()

        await proxy.pollUntil({ !receivedSearchTerms.isEmpty }, timeout: 3)
        #expect(receivedSearchTerms.contains(""))
    }

    @Test
    func lookup_searchAndSelect_prefillsFormWithSelectedAddress() async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress },
                hideForCardBrands: Self.anyHideForCardBrands
            )
        )

        await proxy.load()
        proxy.fillCardDetails()

        let lookupVC = try await proxy.openBillingAddressLookup()

        // Trigger search and select the first result via the lookup ViewModel
        try await proxy.searchAndSelectResult(in: lookupVC, searchTerm: "New York", resultIndex: 1)

        // Wait for the form to appear with the prefilled address
        await proxy.pollUntil(
            { lookupVC.viewControllers.last is AddressInputFormViewController },
            timeout: 3
        )
        let addressFormVC = try #require(
            lookupVC.viewControllers.last as? AddressInputFormViewController
        )
        #expect(addressFormVC.addressItem.value == expectedAddress)

        // Tap Done on the form
        addressFormVC.submitTapped()
        await proxy.waitForDismissal()

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test
    func lookup_submitWithoutAddress_showsValidationError_thenSucceedsAfterFilling() async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress },
                hideForCardBrands: Self.anyHideForCardBrands
            )
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.expectBillingAddressShowsValidationError()

        try await proxy.fillBillingAddressViaLookup(expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test
    func lookup_onAddressSelected_isCalled_withSelectedResult() async throws {
        let partialAddress = PostalAddress(city: "New York", country: "US")
        let callbackTracker = CallbackTracker<AddressLookupResult>()

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny-123", postalAddress: partialAddress)]
                },
                onAddressSelected: { result in
                    callbackTracker.record(result)
                    return result.postalAddress
                },
                hideForCardBrands: Self.anyHideForCardBrands
            )
        )

        await proxy.load()
        proxy.fillCardDetails()

        let lookupVC = try await proxy.openBillingAddressLookup()
        try await proxy.searchAndSelectResult(in: lookupVC, searchTerm: "address", resultIndex: 1)

        // Form appears only after onAddressSelected completes
        await proxy.pollUntil(
            { lookupVC.viewControllers.last is AddressInputFormViewController },
            timeout: 3
        )

        #expect(callbackTracker.value?.identifier == "ny-123")
        #expect(callbackTracker.value?.postalAddress == partialAddress)

        // Dismiss without submitting (partial address won't pass validation)
        let addressFormVC = try #require(
            lookupVC.viewControllers.last as? AddressInputFormViewController
        )
        addressFormVC.dismissAddressLookup()
        await proxy.waitForDismissal()
    }

    @Test
    func lookup_onAddressSelected_modifiesAddress_submitsModifiedAddress() async throws {
        let partialAddress = PostalAddress(city: "New York", country: "US")
        let completeAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny-123", postalAddress: partialAddress)]
                },
                onAddressSelected: { _ in
                    // Simulate fetching complete address details from a service
                    completeAddress
                },
                hideForCardBrands: Self.anyHideForCardBrands
            )
        )

        await proxy.load()
        proxy.fillCardDetails()
        try await proxy.fillBillingAddressViaLookup(completeAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == completeAddress)
    }

    // MARK: - Helpers

    private func makeSUT(
        billingAddressMode: BillingAddressMode,
        detectedBrand: CardBrand = anyCardBrand,
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

// MARK: - View Identifiers

private enum ViewIdentifier {
    static let billingAddress = "AdyenCard.CardComponent.billingAddress"
    static let postalCode = "AdyenCard.CardComponent.postalCodeItem"
    static let securityCode = "AdyenCard.CardComponent.securityCodeItem"
    static let expiryDate = "AdyenCard.CardComponent.expiryDateItem"
    static let cardNumber = "AdyenCard.FormCardNumberContainerItem.numberItem"
    static let payButton = "AdyenCard.CardComponent.payButtonItem.button"
}

// MARK: - BillingAddressModeProxy

@MainActor
private struct BillingAddressModeProxy {

    let component: CardComponent

    private let delegate = PaymentComponentDelegateMock()
    private let window = UIWindow(frame: UIScreen.main.bounds)

    /// The card view controller's root view, used for finding subviews by accessibility identifier.
    var cardView: UIView {
        component.cardViewController.view
    }

    init(component: CardComponent) {
        self.component = component
        component.delegate = delegate
    }

    // MARK: - Lifecycle

    func load() async {
        window.rootViewController = component.viewController
        window.makeKeyAndVisible()
        window.layer.speed = 10
        await yieldTasks(count: 10)
    }

    // MARK: - Visibility Assertions

    func expectBillingAddressPickerVisible(_ expected: Bool, timeout: TimeInterval = 3) async {
        let billingAddressView: FormAddressPickerItemView? = cardView.findView(by: ViewIdentifier.billingAddress)
        if billingAddressView == nil {
            #expect(expected == false, "billingAddressPickerItem view not found, expected visible=\(expected)")
            return
        }
        await pollUntil({ billingAddressView?.item.isVisible == expected }, timeout: timeout)
    }

    func expectPostalCodeVisible(_ expected: Bool, timeout: TimeInterval = 3) async {
        let postalCodeView: FormTextItemView<FormPostalCodeItem>? = cardView.findView(by: ViewIdentifier.postalCode)
        await pollUntil({ postalCodeView?.item.isVisible == expected }, timeout: timeout)
    }

    /// Opens address form, asserts country picker contains exactly these codes, then dismisses.
    func expectAddressFormCountryPicker(containsExactly expectedCodes: [String], selectedCountry: String? = nil) async throws {
        let addressFormVC = try await openBillingAddressForm()
        let countryCodes = addressFormVC.addressItem.countryPickerItem.selectableValues.map(\.identifier)
        #expect(countryCodes.sorted() == expectedCodes.sorted(), "Expected countries \(expectedCodes.sorted()), got \(countryCodes.sorted())")
        if let selectedCountry {
            #expect(addressFormVC.addressItem.countryPickerItem.value?.identifier == selectedCountry)
        }
        addressFormVC.dismissAddressLookup()
        await waitForDismissal()
    }

    /// Opens address form, asserts country picker contains at least these codes, then dismisses.
    func expectAddressFormCountryPicker(containsAtLeast expectedCodes: [String]) async throws {
        let addressFormVC = try await openBillingAddressForm()
        let countryCodes = Set(addressFormVC.addressItem.countryPickerItem.selectableValues.map(\.identifier))
        for code in expectedCodes {
            #expect(countryCodes.contains(code), "Expected country \(code) to be in picker")
        }
        #expect(countryCodes.count > expectedCodes.count, "Expected more than \(expectedCodes.count) countries")
        addressFormVC.dismissAddressLookup()
        await waitForDismissal()
    }

    /// Asserts that submitting without a billing address shows a validation error on the billing address picker.
    func expectBillingAddressShowsValidationError() async throws {
        let billingAddressView: FormAddressPickerItemView = try #require(
            cardView.findView(by: ViewIdentifier.billingAddress)
        )
        #expect(billingAddressView.isShowingValidationError == false)

        await tapSubmitAndExpectNoCallback()
        #expect(billingAddressView.isShowingValidationError == true)
    }

    // MARK: - User Actions

    /// Fills in valid card details (number, expiry, CVC).
    /// The actual brand detection is controlled by `detectedBrand` in `makeSUT()`, not by the card number.
    func fillCardDetails() {
        let securityCodeField: FormCardSecurityCodeItemView? = cardView.findView(by: ViewIdentifier.securityCode)
        let expiryDateField: FormTextInputItemView? = cardView.findView(by: ViewIdentifier.expiryDate)
        let numberField: FormCardNumberItemView? = cardView.findView(by: ViewIdentifier.cardNumber)

        populate(securityCodeField, with: "737")
        populate(numberField, with: "4111 1120 1426 7661")
        populate(expiryDateField, with: "12/30")
    }

    func fillPostalCode(_ value: String) {
        let postalCodeField: FormTextItemView<FormPostalCodeItem>? = cardView.findView(by: ViewIdentifier.postalCode)
        populate(postalCodeField, with: value)
    }

    /// Simulates the `.full` mode user flow:
    /// tap billing address picker -> fill address fields via views -> tap Done.
    func fillBillingAddressViaForm(with address: PostalAddress) async throws {
        let addressFormVC = try await openBillingAddressForm()
        fillAddressFields(in: addressFormVC.view, with: address)
        addressFormVC.submitTapped()
        await waitForDismissal()
    }

    /// Simulates the `.lookup` mode user flow:
    /// tap billing address picker -> search -> select result -> form prefilled -> tap Done.
    func fillBillingAddressViaLookup(_ address: PostalAddress) async throws {
        let lookupVC = try await openBillingAddressLookup()

        // Trigger a search and select the first result (index 1, since index 0 is "manual entry")
        try await searchAndSelectResult(in: lookupVC, searchTerm: "address", resultIndex: 1)

        // Wait for the form to appear with the prefilled address
        await pollUntil(
            { lookupVC.viewControllers.last is AddressInputFormViewController },
            timeout: 3
        )
        let addressFormVC = try #require(
            lookupVC.viewControllers.last as? AddressInputFormViewController
        )

        addressFormVC.submitTapped()
        await waitForDismissal()
    }

    /// Opens the billing address picker and returns the presented `AddressInputFormViewController`.
    func openBillingAddressForm() async throws -> AddressInputFormViewController {
        let billingAddressView: FormAddressPickerItemView = try #require(
            cardView.findView(by: ViewIdentifier.billingAddress),
            "Billing address picker view not found"
        )
        tap(billingAddressView)
        return try await waitForPresentedAddressInputForm()
    }

    /// Opens the billing address picker and returns the presented `AddressLookupViewController`.
    func openBillingAddressLookup() async throws -> AddressLookupViewController {
        let billingAddressView: FormAddressPickerItemView = try #require(
            cardView.findView(by: ViewIdentifier.billingAddress),
            "Billing address picker view not found"
        )
        tap(billingAddressView)
        return try await waitForPresentedAddressLookupVC()
    }

    /// Programmatically triggers a search on the lookup ViewModel and selects a result at the given index.
    func searchAndSelectResult(
        in lookupVC: AddressLookupViewController,
        searchTerm: String,
        resultIndex: Int
    ) async throws {
        let searchVM = lookupVC.viewModel.buildAddressSearchViewModel { _ in }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            searchVM.handleLookUp(searchTerm: searchTerm) { listItems in
                guard resultIndex < listItems.count else {
                    continuation.resume(throwing: TestError(message: "Result index \(resultIndex) out of bounds (\(listItems.count) items)"))
                    return
                }
                listItems[resultIndex].selectionHandler?()
                continuation.resume()
            }
        }
    }

    /// Taps submit and verifies that the delegate is NOT called (validation blocks submission).
    func tapSubmitAndExpectNoCallback() async {
        var delegateWasCalled = false
        delegate.onDidSubmit = { _, _ in delegateWasCalled = true }
        delegate.onDidFail = { _, _ in delegateWasCalled = true }

        tapSubmitButton()
        await yieldTasks(count: 20)

        #expect(delegateWasCalled == false, "Delegate should not be called when validation fails")
    }

    func submit(timeout: TimeInterval = 3) async throws -> PaymentComponentData {
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
                continuation.resume(throwing: TestError(message: "Submit timed out"))
            }
        }
    }

    // MARK: - Waiting

    func waitForDismissal(timeout: TimeInterval = 3) async {
        await pollUntil({ component.viewController.presentedViewController == nil }, timeout: timeout)
    }

    func pollUntil(_ condition: () -> Bool, timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            await yieldTasks(count: 10)
        }
        #expect(condition())
    }

    // MARK: - Private Helpers

    private func populate(_ itemView: (some FormTextItemView<some FormTextItem>)?, with text: String) {
        guard let itemView else { return }
        itemView.textField.text = text
        itemView.textField.sendActions(for: .editingChanged)
    }

    private func tapSubmitButton() {
        let payButton: UIControl? = component.viewController.view.findView(
            with: ViewIdentifier.payButton
        )
        payButton?.sendActions(for: .touchUpInside)
    }

    /// Simulates a user tap on a selectable view by sending touchUpInside to its embedded button.
    private func tap(_ selectableView: UIView) {
        guard let button = selectableView.subviews.first(where: { $0 is UIButton }) as? UIButton else { return }
        button.sendActions(for: .touchUpInside)
    }

    /// Fills address form fields by finding views via accessibility identifiers.
    private func fillAddressFields(in formView: UIView, with address: PostalAddress) {
        let prefix = "AddressInputFormViewController.address"

        if let street = address.street {
            let view: FormTextInputItemView? = formView.findView(with: "\(prefix).street")
            populate(view, with: street)
        }
        if let houseNumber = address.houseNumberOrName {
            let view: FormTextInputItemView? = formView.findView(with: "\(prefix).houseNumberOrName")
            populate(view, with: houseNumber)
        }
        if let city = address.city {
            let view: FormTextInputItemView? = formView.findView(with: "\(prefix).city")
            populate(view, with: city)
        }
        if let postalCode = address.postalCode {
            let view: FormTextInputItemView? = formView.findView(with: "\(prefix).postalCode")
            populate(view, with: postalCode)
        }
        if let apartment = address.apartment {
            let view: FormTextInputItemView? = formView.findView(with: "\(prefix).apartment")
            populate(view, with: apartment)
        }
        if let stateOrProvince = address.stateOrProvince {
            let picker: FormPickerItemView<FormPickerElement>? = formView.findView(with: "\(prefix).stateOrProvince")
            if let picker, let match = picker.item.selectableValues.first(where: { $0.identifier == stateOrProvince }) {
                picker.item.value = match
            }
        }
    }

    private func waitForPresentedAddressInputForm(timeout: TimeInterval = 3) async throws -> AddressInputFormViewController {
        await pollUntil({ component.viewController.presentedViewController != nil }, timeout: timeout)

        let securedVC = try #require(
            component.viewController.presentedViewController as? SecuredViewController<UIViewController>,
            "Expected SecuredViewController to be presented"
        )
        let navController = try #require(
            securedVC.childViewController as? UINavigationController,
            "Expected UINavigationController inside SecuredViewController"
        )
        return try #require(
            navController.viewControllers.first as? AddressInputFormViewController,
            "Expected AddressInputFormViewController as root of UINavigationController"
        )
    }

    private func waitForPresentedAddressLookupVC(timeout: TimeInterval = 3) async throws -> AddressLookupViewController {
        await pollUntil({ component.viewController.presentedViewController != nil }, timeout: timeout)

        let securedVC = try #require(
            component.viewController.presentedViewController as? SecuredViewController<UIViewController>,
            "Expected SecuredViewController to be presented"
        )
        return try #require(
            securedVC.childViewController as? AddressLookupViewController,
            "Expected AddressLookupViewController inside SecuredViewController"
        )
    }

    private func yieldTasks(count: Int) async {
        for _ in 0..<count {
            await Task.yield()
        }
    }
}

private struct TestError: Error {
    let message: String
}

private final class CallbackTracker<T: Sendable>: @unchecked Sendable {
    private(set) var value: T?

    func record(_ value: T) {
        self.value = value
    }
}
