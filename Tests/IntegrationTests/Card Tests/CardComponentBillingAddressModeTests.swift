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
struct CardComponentBillingAddressModeTests {

    // MARK: - Arbitrary test values (do not influence outcomes)

    private static let anySupportedCountryCodes = ["US"]
    private static let anyCardBrand = CardBrand.visa
    private static let anyHideForCardBrands: Set<CardBrand> = []
    private static let anyOnAddressLookup: (String) async -> [AddressLookupResult] = { _ in [] }
    private static let anySearchTerm = "searchTerm"

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

    @Test
    func none_analytics_excludesBillingAddressKeys() throws {
        let configData = try analyticsConfigData(for: BillingAddressMode.none)

        #expect(configData["billingAddressMode"] == nil)
        #expect(configData["billingAddressAllowedCountries"] == nil)
        #expect(configData["billingAddressHideForCardBrands"] == "")
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
        try await proxy.expectAddressFormCountryPicker(containsExactly: ["US", "NL"], selectedCountry: "US")
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
    func full_supportedCountryCodes_withNonMatchingPrefill_selectsFirstSupportedCountry() async throws {
        // The prefilled billing address country (US) is not in the supported list,
        // so the country picker should fall back to the first supported country.
        let nonMatchingPrefill = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: ["UK"], hideForCardBrands: []),
            shopperInformation: PrefilledShopperInformation(billingAddress: nonMatchingPrefill)
        )

        await proxy.load()
        proxy.fillCardDetails()
        try await proxy.expectAddressFormCountryPicker(containsExactly: ["UK"], selectedCountry: "UK")
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

        try await proxy.submitAndExpectBillingAddressValidationError()

        try await proxy.fillBillingAddressViaForm(with: expectedAddress)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test
    func full_analytics_reportsModeAndCountries() throws {
        let configData = try analyticsConfigData(for: .full(supportedCountryCodes: ["US", "NL"], hideForCardBrands: Self.anyHideForCardBrands))

        #expect(configData["billingAddressMode"] == "full")
        #expect(configData["billingAddressAllowedCountries"] == "US,NL")
        #expect(configData["billingAddressHideForCardBrands"] == "")
    }

    @Test
    func full_analytics_withHideForCardBrands_reportsSortedBrands() throws {
        let configData = try analyticsConfigData(
            for: .full(supportedCountryCodes: Self.anySupportedCountryCodes, hideForCardBrands: [.visa, .masterCard])
        )

        #expect(configData["billingAddressMode"] == "full")
        #expect(configData["billingAddressHideForCardBrands"] == "mc,visa")
    }

    @Test
    func full_withPrefilledBillingAddress_prefillsAndSubmitsAddress() async throws {
        let prefilledAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: Self.anySupportedCountryCodes, hideForCardBrands: []),
            shopperInformation: PrefilledShopperInformation(billingAddress: prefilledAddress)
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        // Opening the address form for editing shows the prefilled address.
        try await proxy.expectAddressFormPrefilled(with: prefilledAddress)

        // No manual address entry — the prefilled value should be submitted as-is.
        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == prefilledAddress)
    }

    @Test
    func full_withPrefilledBillingAddress_andHiddenBrand_hidesAndSubmitsNil() async throws {
        let prefilledAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .full(supportedCountryCodes: Self.anySupportedCountryCodes, hideForCardBrands: [CardBrand.visa]),
            detectedBrand: CardBrand.visa,
            shopperInformation: PrefilledShopperInformation(billingAddress: prefilledAddress)
        )

        await proxy.load()
        await proxy.expectBillingAddressPickerVisible(true)

        // A card whose brand is configured to hide the address must hide it even though it was
        // prefilled, and the prefilled value must not be submitted.
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(false)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == nil)
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

    @Test
    func postalCode_submitWithoutPostalCode_showsValidationError_thenSucceedsAfterFilling() async throws {
        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: Self.anyHideForCardBrands)
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectPostalCodeVisible(true)

        // Submit without filling postal code — should show validation error
        try await proxy.submitAndExpectPostalCodeValidationError()

        // Fill the postal code
        proxy.fillPostalCode("12345")

        // Submit again — should succeed
        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == PostalAddress(postalCode: "12345"))
    }

    @Test
    func postalCode_analytics_reportsModeAsPartial() throws {
        let configData = try analyticsConfigData(for: .postalCode(hideForCardBrands: Self.anyHideForCardBrands))

        #expect(configData["billingAddressMode"] == "partial")
        #expect(configData["billingAddressAllowedCountries"] == nil)
        #expect(configData["billingAddressHideForCardBrands"] == "")
    }

    @Test
    func postalCode_analytics_withHideForCardBrands_reportsBrands() throws {
        let configData = try analyticsConfigData(for: .postalCode(hideForCardBrands: [.visa]))

        #expect(configData["billingAddressMode"] == "partial")
        #expect(configData["billingAddressHideForCardBrands"] == "visa")
    }

    @Test
    func postalCode_withPrefilledBillingAddress_prefillsAndSubmitsPostalCode() async throws {
        let prefilledAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .postalCode(hideForCardBrands: []),
            shopperInformation: PrefilledShopperInformation(billingAddress: prefilledAddress)
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectPostalCodeVisible(true)

        // Postal code mode only submits the postal code portion of the prefilled address.
        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == PostalAddress(postalCode: prefilledAddress.postalCode))
    }

    // MARK: - .lookup

    @Test
    func lookup_hideForMatchingCard_hidesLookup_submitsNilBillingAddress() async throws {
        let proxy = makeSUT(
            billingAddressMode: .lookup(hideForCardBrands: [CardBrand.visa], onAddressLookup: Self.anyOnAddressLookup),
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
                hideForCardBrands: [CardBrand.jcb],
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress }
            ),
            detectedBrand: CardBrand.visa
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.fillBillingAddressViaLookup(searchTerm: Self.anySearchTerm)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test(arguments: [CardBrand.visa, .masterCard, .americanExpress, .jcb, .discover, .maestro])
    func lookup_hideForEmptyBrands_neverHides(detectedBrand: CardBrand) async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                hideForCardBrands: [],
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress }
            ),
            detectedBrand: detectedBrand
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.fillBillingAddressViaLookup(searchTerm: Self.anySearchTerm)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test
    func lookup_onAddressLookup_isCalled() async throws {
        let expectedSearchTerm = "123 Main Street"
        var receivedSearchTerms: [String] = []

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                hideForCardBrands: Self.anyHideForCardBrands,
                onAddressLookup: { searchTerm in
                    receivedSearchTerms.append(searchTerm)
                    return []
                }
            )
        )

        await proxy.load()
        proxy.fillCardDetails()

        let lookupVC = try await proxy.openBillingAddressLookup()
        await proxy.triggerSearch(in: lookupVC, searchTerm: expectedSearchTerm)

        #expect(receivedSearchTerms.contains(expectedSearchTerm))
    }

    @Test
    func lookup_searchAndSelect_prefillsFormWithSelectedAddress() async throws {
        let expectedAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                hideForCardBrands: Self.anyHideForCardBrands,
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress }
            )
        )

        await proxy.load()
        proxy.fillCardDetails()

        let addressFormVC = try await proxy.searchAndSelectAddressFromLookup(searchTerm: "New York")
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
                hideForCardBrands: Self.anyHideForCardBrands,
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny", postalAddress: expectedAddress)]
                },
                onAddressSelected: { $0.postalAddress }
            )
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        try await proxy.submitAndExpectBillingAddressValidationError()

        try await proxy.fillBillingAddressViaLookup(searchTerm: Self.anySearchTerm)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == expectedAddress)
    }

    @Test
    func lookup_onAddressSelected_modifiesAddress_submitsModifiedAddress() async throws {
        let partialAddress = PostalAddress(city: "New York", country: "US")
        let completeAddress = PostalAddressMocks.newYorkPostalAddress

        let proxy = makeSUT(
            billingAddressMode: .lookup(
                hideForCardBrands: Self.anyHideForCardBrands,
                onAddressLookup: { _ in
                    [AddressLookupResult(identifier: "ny-123", postalAddress: partialAddress)]
                },
                onAddressSelected: { _ in
                    completeAddress
                }
            )
        )

        await proxy.load()
        proxy.fillCardDetails()
        try await proxy.fillBillingAddressViaLookup(searchTerm: Self.anySearchTerm)

        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == completeAddress)
    }

    @Test
    func lookup_analytics_reportsModeAsLookup() throws {
        let configData = try analyticsConfigData(
            for: .lookup(hideForCardBrands: Self.anyHideForCardBrands, onAddressLookup: Self.anyOnAddressLookup)
        )

        #expect(configData["billingAddressMode"] == "lookup")
        #expect(configData["billingAddressAllowedCountries"] == nil)
        #expect(configData["billingAddressHideForCardBrands"] == "")
    }

    @Test
    func lookup_analytics_withHideForCardBrands_reportsBrands() throws {
        let configData = try analyticsConfigData(
            for: .lookup(hideForCardBrands: [.jcb], onAddressLookup: Self.anyOnAddressLookup)
        )

        #expect(configData["billingAddressMode"] == "lookup")
        #expect(configData["billingAddressHideForCardBrands"] == "jcb")
    }

    @Test
    func lookup_withPrefilledBillingAddress_prefillsAndSubmitsAddress() async throws {
        let prefilledAddress = PostalAddressMocks.newYorkPostalAddress

        final class LookupInvocationTracker: @unchecked Sendable { var wasCalled = false }
        let lookupTracker = LookupInvocationTracker()

        let proxy = makeSUT(
            billingAddressMode: .lookup(hideForCardBrands: [], onAddressLookup: { _ in
                lookupTracker.wasCalled = true
                return []
            }),
            shopperInformation: PrefilledShopperInformation(billingAddress: prefilledAddress)
        )

        await proxy.load()
        proxy.fillCardDetails()
        await proxy.expectBillingAddressPickerVisible(true)

        // No manual lookup/selection — the prefilled value should be submitted as-is.
        let submittedData = try await proxy.submit()
        #expect(submittedData.billingAddress == prefilledAddress)

        // Prefilling must not trigger the lookup handler.
        #expect(lookupTracker.wasCalled == false, "Lookup handler should not be called for a prefilled address")
    }

    // MARK: - Helpers

    /// Returns the analytics `configData` dictionary for a given billing address mode.
    private func analyticsConfigData(for billingAddressMode: BillingAddressMode) throws -> [String: String] {
        let analyticsProvider = AnalyticsProviderMock()
        var configuration = CardConfiguration()
        configuration.billingAddressMode = billingAddressMode

        let method = CardPaymentMethod(
            type: .bcmc,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )

        let component = CardComponent(
            paymentMethod: method,
            context: Dummy.context(analyticsProvider: analyticsProvider),
            configuration: configuration
        )
        component.viewDidLoad(viewController: component.cardViewController)

        return try #require(analyticsProvider.infos.first?.configData?.stringOnlyDictionary)
    }

    private func makeSUT(
        billingAddressMode: BillingAddressMode,
        detectedBrand: CardBrand = anyCardBrand,
        shopperInformation: PrefilledShopperInformation? = nil
    ) -> CardComponentProxy {
        var proxy: CardComponentProxy!
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

            proxy = CardComponentProxy(component: component)
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

// MARK: - CardComponentProxy

@MainActor
private struct CardComponentProxy {

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
        await pollUntil({
            let view: FormAddressPickerItemView? = self.cardView.findView(by: ViewIdentifier.billingAddress)
            return self.isViewVisibleOnScreen(view) == expected
        }, timeout: timeout)
    }

    func expectPostalCodeVisible(_ expected: Bool, timeout: TimeInterval = 3) async {
        await pollUntil({
            let view: FormTextItemView<FormPostalCodeItem>? = self.cardView.findView(by: ViewIdentifier.postalCode)
            return self.isViewVisibleOnScreen(view) == expected
        }, timeout: timeout)
    }

    private func isViewVisibleOnScreen(_ view: UIView?) -> Bool {
        guard let view, view.window != nil else { return false }
        var current: UIView? = view
        while let candidate = current {
            if candidate.isHidden || candidate.alpha < 0.01 { return false }
            current = candidate.superview
        }
        return true
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

    /// Opens the billing address form and asserts it is prefilled with the expected address, then dismisses it.
    func expectAddressFormPrefilled(with expectedAddress: PostalAddress) async throws {
        let addressFormVC = try await openBillingAddressForm()
        #expect(addressFormVC.addressItem.value == expectedAddress)
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

    /// Submits the form without a postal code and asserts a validation error appears on the postal code field.
    func submitAndExpectPostalCodeValidationError() async throws {
        let postalCodeView: FormTextItemView<FormPostalCodeItem> = try #require(
            cardView.findView(by: ViewIdentifier.postalCode)
        )
        #expect(postalCodeView.isShowingValidationError == false)

        await tapSubmitAndExpectNoCallback()
        #expect(postalCodeView.isShowingValidationError == true)
    }

    /// Submits the form without a billing address and asserts a validation error appears on the billing address picker.
    func submitAndExpectBillingAddressValidationError() async throws {
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
    func fillBillingAddressViaLookup(searchTerm: String) async throws {
        let addressFormVC = try await searchAndSelectAddressFromLookup(searchTerm: searchTerm)
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

    /// Opens the lookup picker, searches, selects the result at `resultIndex` (index 0 is manual entry),
    /// and returns the resulting address form prefilled with the selection.
    func searchAndSelectAddressFromLookup(
        searchTerm: String,
        resultIndex: Int = 1
    ) async throws -> AddressInputFormViewController {
        let lookupVC = try await openBillingAddressLookup()
        try await searchAndSelectResult(in: lookupVC, searchTerm: searchTerm, resultIndex: resultIndex)
        await pollUntil({ lookupVC.viewControllers.last is AddressInputFormViewController }, timeout: 3)
        return try #require(lookupVC.viewControllers.last as? AddressInputFormViewController)
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

    /// Programmatically triggers a search on the lookup ViewModel without selecting a result.
    func triggerSearch(
        in lookupVC: AddressLookupViewController,
        searchTerm: String
    ) async {
        let searchVM = lookupVC.viewModel.buildAddressSearchViewModel { _ in }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            searchVM.handleLookUp(searchTerm: searchTerm) { _ in
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

        let component = self.component
        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false

            delegate.onDidSubmit = { data, _ in
                guard !didResume else { return }
                didResume = true
                component.stopLoading()
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
