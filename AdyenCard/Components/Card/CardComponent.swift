//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation
import UIKit

/**
  A component that provides a form for card payments.

 - SeeAlso:
 [Implementation guidelines](https://docs.adyen.com/payment-methods/cards/ios-component)
 */
public class CardComponent: PresentableComponent,
    PaymentAware,
    LoadingComponent {

    internal enum Constant {
        internal static let defaultCountryCode = "US"
        internal static let secondsThrottlingDelay = 0.5
        internal static let thresholdBINLength = 11
        internal static let publicPanSuffixLength = 4
    }
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    internal let cardPaymentMethod: AnyCardPaymentMethod

    @_spi(AdyenInternal)
    public let publicKeyProvider: AnyPublicKeyProvider

    internal let binInfoProvider: AnyBinInfoProvider
    
    /// The card payment method.
    public var paymentMethod: PaymentMethod { cardPaymentMethod }

    /// The delegate for user activity on card component.
    public weak var cardComponentDelegate: CardComponentDelegate?

    /// The supported card types.
    public let supportedCardTypes: [CardType]

    /// Card component configuration.
    public private(set) var configuration: Configuration
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate? {
        didSet {
            storedCardComponent?.delegate = delegate
            // override installment config if using session (when session is set as delegate)
            if let installmentAware = delegate as? InstallmentConfigurationAware,
               installmentAware.isSession {
                configuration.installmentConfiguration = installmentAware.installmentConfiguration
            }
            
            if let storePaymentMethodAware = delegate as? StorePaymentMethodFieldAware,
               storePaymentMethodAware.isSession {
                configuration.showsStorePaymentMethodField = storePaymentMethodAware.showStorePaymentMethodField ?? false
            }
        }
    }
    
    /// The partial payment order if any.
    public var order: PartialPaymentOrder? {
        didSet {
            storedCardComponent?.order = order
        }
    }
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The configuration of the component.
    public convenience init(paymentMethod: AnyCardPaymentMethod,
                            context: AdyenContext,
                            configuration: Configuration = .init()) {
        let publicKeyProvider = PublicKeyProvider(apiContext: context.apiContext)
        let binInfoProvider = BinInfoProvider(apiClient: APIClient(apiContext: context.apiContext),
                                              publicKeyProvider: publicKeyProvider,
                                              minBinLength: Constant.thresholdBINLength,
                                              binLookupType: configuration.binLookupType)
        self.init(paymentMethod: paymentMethod,
                  context: context,
                  configuration: configuration,
                  publicKeyProvider: publicKeyProvider,
                  binProvider: binInfoProvider)
    }
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The Card component configuration.
    ///   - publicKeyProvider: The public key provider
    ///   - binProvider: Any object capable to provide a BinInfo.
    internal init(paymentMethod: AnyCardPaymentMethod,
                  context: AdyenContext,
                  configuration: Configuration,
                  publicKeyProvider: AnyPublicKeyProvider,
                  binProvider: AnyBinInfoProvider) {
        self.cardPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.publicKeyProvider = publicKeyProvider
        self.binInfoProvider = binProvider

        self.supportedCardTypes = configuration.allowedCardTypes ?? paymentMethod.brands
    }
    
    // MARK: - Presentable Component Protocol
    
    public var viewController: UIViewController {
        if let storedCardComponent {
            return storedCardComponent.viewController
        }
        return securedViewController
    }
    
    public var requiresModalPresentation: Bool { storedCardComponent?.requiresModalPresentation ?? true }
    
    public func stopLoading() {
        cardViewController.stopLoading()
    }
    
    // MARK: - Stored Card
    
    internal lazy var storedCardComponent: (PaymentComponent & PresentableComponent)? = {
        guard let paymentMethod = paymentMethod as? StoredCardPaymentMethod else {
            return nil
        }
        var component: PaymentComponent & PresentableComponent
        if configuration.stored.showsSecurityCodeField {
            let storedComponent = StoredCardComponent(storedCardPaymentMethod: paymentMethod, context: context)
            storedComponent.localizationParameters = configuration.localizationParameters
            component = storedComponent
        } else {
            let storedConfiguration: StoredPaymentMethodComponent.Configuration
            storedConfiguration = .init(localizationParameters: configuration.localizationParameters)
            let storedComponent = StoredPaymentMethodComponent(paymentMethod: paymentMethod,
                                                               context: context,
                                                               configuration: storedConfiguration)
            component = storedComponent
        }
        return component
    }()
    
    /// Updates the visibility of the store payment method switch.
    ///
    /// - Parameter isVisible: Indicates whether to show the switch if `true` or to hide it if `false`.
    public func update(storePaymentMethodFieldVisibility isVisible: Bool) {
        cardViewController.update(storePaymentMethodFieldVisibility: isVisible)
    }

    public func update(storePaymentMethodFieldValue isOn: Bool) {
        cardViewController.update(storePaymentMethodFieldValue: isOn)
    }

    // MARK: - Form Items
    
    private lazy var securedViewController = SecuredViewController(child: cardViewController, style: configuration.style)
    
    internal lazy var cardViewController: CardViewController = {
        
        let formViewController = CardViewController(configuration: configuration,
                                                    shopperInformation: configuration.shopperInformation,
                                                    formStyle: configuration.style,
                                                    payment: payment,
                                                    logoProvider: LogoURLProvider(environment: context.apiContext.environment),
                                                    supportedCardTypes: supportedCardTypes,
                                                    initialCountryCode: initialCountryCode,
                                                    scope: String(describing: self),
                                                    localizationParameters: configuration.localizationParameters)
        formViewController.delegate = self
        formViewController.cardDelegate = self
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        return formViewController
    }()
    
    private let panThrottler = Throttler(minimumDelay: CardComponent.Constant.secondsThrottlingDelay)
    private let binThrottler = Throttler(minimumDelay: CardComponent.Constant.secondsThrottlingDelay)
}

extension CardComponent: CardViewControllerDelegate {
    
    internal func didChange(pan: String) {
        panThrottler.throttle { [weak self] in
            self?.updateBrand(with: pan)
        }
    }
    
    internal func didChange(bin: String) {
        binThrottler.throttle { [weak self] in
            guard let self else { return }
            self.cardComponentDelegate?.didChangeBIN(bin, component: self)
        }
    }
    
    private func updateBrand(with pan: String) {
        binInfoProvider.provide(for: pan, supportedTypes: supportedCardTypes) { [weak self] binInfo in
            guard let self else { return }
            self.cardViewController.update(binInfo: binInfo)
            self.cardComponentDelegate?.didChangeCardBrand(binInfo.brands ?? [], component: self)
        }
    }
}

@_spi(AdyenInternal)
extension CardComponent: PublicKeyConsumer {}

private extension CardComponent {
    
    private var initialCountryCode: String {
        
        if
            let preferredCountry = configuration.shopperInformation?.billingAddress?.country,
            let supportedCountryCodes = configuration.billingAddress.countryCodes,
            supportedCountryCodes.isEmpty || supportedCountryCodes.contains(preferredCountry) {
            return preferredCountry
        }
        
        return
            configuration.billingAddress.countryCodes?.first ??
            payment?.countryCode ??
            Locale.current.regionCode ??
            CardComponent.Constant.defaultCountryCode
    }
}

private extension CardComponent.Configuration {
    
    func addressLookupViewModel(
        with initialCountry: String,
        prefillAddress: PostalAddress?,
        lookupProvider: AddressLookupProvider,
        completionHandler: @escaping (PostalAddress?) -> Void
    ) -> AddressLookupViewController.ViewModel {
        
        .init(
            for: .billing,
            localizationParameters: localizationParameters,
            supportedCountryCodes: billingAddress.countryCodes,
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
            supportedCountryCodes: billingAddress.countryCodes,
            addressViewModelBuilder: DefaultAddressViewModelBuilder(),
            handleShowSearch: nil,
            completionHandler: completionHandler
        )
    }
}
