//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif
import Foundation
import UIKit

/**
 A component that provides a form for card payments.

 - SeeAlso:
 [Implementation guidelines](https://docs.adyen.com/payment-methods/cards/ios-component)
 */
@MainActor
package class CardComponent: PresentablePaymentComponent,
    LoadingComponent {

    internal enum Constant {
        internal static let defaultCountryCode = "US"
        internal static let secondsThrottlingDelay = 0.5
        internal static let thresholdBINLength = 11
        internal static let publicPanSuffixLength = 4
    }

    /// The context object for this component.
    package let context: AdyenContext

    internal let cardPaymentMethod: AnyCardPaymentMethod

    internal let binInfoProvider: AnyBinInfoProvider

    /// The card payment method.
    package var paymentMethod: PaymentMethod {
        cardPaymentMethod
    }

    /// The supported card types.
    package let supportedCardBrands: [CardBrand]

    /// Card component configuration.
    package internal(set) var configuration: CardConfiguration

    /// Localization parameters with the component-resolved ``CheckoutLocalizationProvider``
    /// attached, used for all card UI string lookups.
    private var resolvedLocalizationParameters: LocalizationParameters? {
        guard let provider = configuration.localizationProvider else {
            return configuration.localizationParameters
        }
        return (configuration.localizationParameters ?? LocalizationParameters()).withProvider(provider)
    }

    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    /// The partial payment order if any.
    package var order: PartialPaymentOrder?

    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The configuration of the component.
    package convenience init(
        paymentMethod: AnyCardPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration = .init()
    ) {
        let binInfoProvider = BinInfoProvider(
            apiClient: APIClient(apiContext: context.apiContext),
            adyenContext: context,
            minBinLength: Constant.thresholdBINLength,
            binLookupType: configuration.binLookupType
        )
        self.init(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            binProvider: binInfoProvider
        )
    }

    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The Card component configuration.
    ///   - binProvider: Any object capable to provide a BinInfo.
    internal init(
        paymentMethod: AnyCardPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration,
        binProvider: AnyBinInfoProvider
    ) {
        self.cardPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.binInfoProvider = binProvider

        self.supportedCardBrands = configuration.supportedCardBrands ?? paymentMethod.brands
    }

    // MARK: - Presentable Component Protocol

    package var viewController: UIViewController {
        securedViewController
    }

    package func stopLoading() {
        cardViewController.stopLoading()
    }

    /// Updates the visibility of the store payment method switch.
    ///
    /// - Parameter isVisible: Indicates whether to show the switch if `true` or to hide it if `false`.
    package func update(storePaymentMethodFieldVisibility isVisible: Bool) {
        cardViewController.update(storePaymentMethodFieldVisibility: isVisible)
    }

    package func update(storePaymentMethodFieldValue isOn: Bool) {
        cardViewController.update(storePaymentMethodFieldValue: isOn)
    }

    // MARK: - Form Items

    private lazy var securedViewController = SecuredViewController(child: cardViewController, style: configuration.style)

    internal lazy var cardViewController: CardViewController = {

        let formViewController = CardViewController(
            configuration: configuration,
            shopperInformation: configuration.shopperInformation,
            formStyle: configuration.style,
            amount: context.amount,
            logoProvider: LogoURLProvider(environment: context.apiContext.environment),
            supportedCardBrands: supportedCardBrands,
            initialCountryCode: initialCountryCode,
            scope: String(describing: self),
            localizationParameters: resolvedLocalizationParameters,
            theme: configuration.theme,
            cardScannerAnalyticsHandler: { [weak self] logSubType in
                self?.sendCardScannerLogEvent(logSubType)
            }
        )

        formViewController.delegate = self
        formViewController.cardDelegate = self
        formViewController.title = paymentMethod.displayInformation(using: resolvedLocalizationParameters).title

        formViewController.items.onDidTriggerInfoEvent = { [weak self] infoEventData in
            self?.sendInfoEvent(with: infoEventData)
        }

        return formViewController
    }()

    private let panThrottler = Throttler(minimumDelay: CardComponent.Constant.secondsThrottlingDelay)

    private func sendInfoEvent(with data: CardViewController.InfoEventData) {
        var infoEvent = AnalyticsEventInfo(
            component: paymentMethod.type.rawValue,
            type: data.type
        )
        infoEvent.target = data.target
        infoEvent.brand = data.brands?.first?.brand.rawValue

        // Send configData only when co-badged cards are displayed
        if data.type == .displayed, infoEvent.target == .dualBrandButton {
            infoEvent.configData = CoBadgedCardAnalyticsConfiguration(dualBrands: data.brands?.map(\.brand.rawValue).joined(separator: ","))
        }
        if let errorCode = data.error?.analyticsErrorCode {
            infoEvent.validationErrorCode = String(errorCode)
        }
        infoEvent.validationErrorMessage = data.error?.analyticsErrorMessage
        context.analyticsProvider?.add(info: infoEvent)
    }
}

extension CardComponent: CardViewControllerDelegate {

    internal func didSelectSubmitButton() {
        self.performSubmit()
    }

    internal func didChange(pan: String) {
        panThrottler.throttle { [weak self] in
            self?.updateBrand(with: pan)
        }
    }

    internal func didChange(bin: String) {
        configuration.onBinChange?(bin)
    }

    private func updateBrand(with pan: String) {
        binInfoProvider.provide(for: pan, supportedTypes: supportedCardBrands) { [weak self] binInfo in
            guard let self else { return }
            self.cardViewController.update(binInfo: binInfo)
            guard !binInfo.isCreatedLocally else { return }
            let brands = (binInfo.brands ?? []).map {
                BinLookupBrand(brand: $0.brand.rawValue, supported: $0.isSupported, paymentMethodVariant: $0.paymentMethodVariant)
            }
            self.configuration.onBinLookup?(BinLookupData(issuingCountryCode: binInfo.issuingCountryCode, brands: brands))
        }
    }
}

private extension CardComponent {

    private var initialCountryCode: String {

        if
            let preferredCountry = configuration.shopperInformation?.billingAddress?.country,
            configuration.billingAddressMode.supports(countryCode: preferredCountry) {
            return preferredCountry
        }

        return
            configuration.billingAddressMode.supportedCountryCodes?.first ??
            Locale.current.regionCode ??
            CardComponent.Constant.defaultCountryCode
    }
}

private extension CardConfiguration {

    func addressLookupViewModel(
        with initialCountry: String,
        prefillAddress: PostalAddress?,
        lookupProvider: AddressLookupProvider,
        completionHandler: @escaping (PostalAddress?) -> Void
    ) -> AddressLookupViewController.ViewModel {

        .init(
            for: .billing,
            localizationParameters: localizationParameters,
            supportedCountryCodes: billingAddressMode.supportedCountryCodes,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            lookupProvider: lookupProvider,
            completionHandler: completionHandler
        )
    }

    func addressInputFormViewModel(
        with initialCountry: String,
        prefillAddress: PostalAddress?,
        completionHandler: @escaping (PostalAddress?) -> Void
    ) -> AddressInputFormViewController.ViewModel {

        .init(
            for: .billing,
            style: style,
            localizationParameters: localizationParameters,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            supportedCountryCodes: billingAddressMode.supportedCountryCodes,
            addressViewModelBuilder: DefaultAddressViewModelBuilder(),
            handleShowSearch: nil,
            completionHandler: completionHandler
        )
    }
}

// MARK: - AdyenCardScanner Analytics

extension CardComponent {

    private func sendCardScannerLogEvent(_ subtype: AnalyticsEventLog.LogSubType) {
        let component = paymentMethod.type.rawValue
        let logEvent = AnalyticsEventLog(
            component: component,
            type: .cardScanner,
            subType: subtype
        )

        context.analyticsProvider?.add(log: logEvent)
    }
}

extension BillingAddressMode {

    internal var supportedCountryCodes: [String]? {
        switch self {
        case let .full(supportedCountryCodes, _):
            return supportedCountryCodes.isEmpty ? nil : supportedCountryCodes
        case .none, .postalCode, .lookup:
            return nil
        }
    }

    internal func supports(countryCode: String) -> Bool {
        guard let supportedCountryCodes else { return true } // nil == all countries supported
        return supportedCountryCodes.contains(countryCode)
    }

    internal var hideForCardBrands: Set<CardBrand> {
        switch self {
        case .none:
            return []
        case let .postalCode(hideForCardBrands):
            return hideForCardBrands
        case let .full(_, hideForCardBrands):
            return hideForCardBrands
        case let .lookup(hideForCardBrands, _, _):
            return hideForCardBrands
        }
    }

    internal func shouldHide(for cardBrands: [CardBrand]) -> Bool {
        !hideForCardBrands.isDisjoint(with: cardBrands)
    }
}
