//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
import UIKit

/**
  A component that provides a form for card payments.

 - SeeAlso:
 [Implementation guidelines](https://docs.adyen.com/payment-methods/cards/ios-component)
 */
public class CardComponent: PublicKeyConsumer,
    PresentableComponent,
    Localizable,
    LoadingComponent {

    internal enum Constant {
        internal static let defaultCountryCode = "US"
        internal static let secondsThrottlingDelay = 0.5
        internal static let publicBinLength = 6
        internal static let privateBinLength = 11
        internal static let publicPanSuffixLength = 4
    }
    
    /// :nodoc:
    public let apiContext: APIContext

    internal let cardPaymentMethod: AnyCardPaymentMethod

    /// :nodoc:
    public let publicKeyProvider: AnyPublicKeyProvider

    internal let binInfoProvider: AnyBinInfoProvider
    
    /// Describes the component's UI style.
    public let style: FormComponentStyle
    
    /// The card payment method.
    public var paymentMethod: PaymentMethod { cardPaymentMethod }

    /// The delegate for user activity on card component.
    public weak var cardComponentDelegate: CardComponentDelegate?

    /// The supported card types.
    public let supportedCardTypes: [CardType]

    /// Card component configuration.
    public let configuration: Configuration

    /// The shopper's information to be prefilled.
    public let shopperInformation: PrefilledShopperInformation?
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate? {
        didSet {
            storedCardComponent?.delegate = delegate
        }
    }

    /// The payment information.
    public var payment: Payment? {
        didSet {
            storedCardComponent?.payment = payment
        }
    }
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - apiContext: The API context.
    ///   - configuration: The configuration of the component.
    ///   - shopperInformation: The shopper's information, optional.
    ///   - style: The Component's UI style.
    public convenience init(paymentMethod: AnyCardPaymentMethod,
                            apiContext: APIContext,
                            configuration: Configuration = Configuration(),
                            shopperInformation: PrefilledShopperInformation? = nil,
                            style: FormComponentStyle = FormComponentStyle()) {
        let publicKeyProvider = PublicKeyProvider(apiContext: apiContext)
        let binInfoProvider = BinInfoProvider(apiClient: APIClient(apiContext: apiContext),
                                              publicKeyProvider: publicKeyProvider,
                                              minBinLength: Constant.privateBinLength)
        self.init(paymentMethod: paymentMethod,
                  apiContext: apiContext,
                  configuration: configuration,
                  shopperInformation: shopperInformation,
                  style: style,
                  publicKeyProvider: publicKeyProvider,
                  binProvider: binInfoProvider)
    }
    
    /// :nodoc:
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - apiContext: The API context.
    ///   - configuration: The Card component configuration.
    ///   - shopperInformation: The shopper's information.
    ///   - style: The Component's UI style.
    ///   - publicKeyProvider: The public key provider
    ///   - binProvider: Any object capable to provide a BinInfo.
    internal init(paymentMethod: AnyCardPaymentMethod,
                  apiContext: APIContext,
                  configuration: Configuration,
                  shopperInformation: PrefilledShopperInformation? = nil,
                  style: FormComponentStyle,
                  publicKeyProvider: AnyPublicKeyProvider,
                  binProvider: AnyBinInfoProvider) {
        self.cardPaymentMethod = paymentMethod
        self.apiContext = apiContext
        self.configuration = configuration
        self.shopperInformation = shopperInformation
        self.style = style
        self.publicKeyProvider = publicKeyProvider
        self.binInfoProvider = binProvider

        let paymentMethodCardTypes = paymentMethod.brands.compactMap(CardType.init)
        let excludedCardTypes = configuration.excludedCardTypes
        let allowedCardTypes = configuration.allowedCardTypes ?? paymentMethodCardTypes
        self.supportedCardTypes = allowedCardTypes.minus(excludedCardTypes)
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        if let storedCardComponent = storedCardComponent {
            return storedCardComponent.viewController
        }
        return securedViewController
    }
    
    /// :nodoc:
    public var requiresModalPresentation: Bool { storedCardComponent?.requiresModalPresentation ?? true }
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
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
            let storedComponent = StoredCardComponent(storedCardPaymentMethod: paymentMethod, apiContext: apiContext)
            storedComponent.localizationParameters = localizationParameters
            component = storedComponent
        } else {
            let storedComponent = StoredPaymentMethodComponent(paymentMethod: paymentMethod, apiContext: apiContext)
            storedComponent.localizationParameters = localizationParameters
            component = storedComponent
        }
        component.payment = payment
        return component
    }()
    
    // MARK: - Form Items
    
    private lazy var securedViewController = SecuredViewController(child: cardViewController, style: style)
    
    internal lazy var cardViewController: CardViewController = {
        let formViewController = CardViewController(configuration: configuration,
                                                    shopperInformation: shopperInformation,
                                                    formStyle: style,
                                                    payment: payment,
                                                    logoProvider: LogoURLProvider(environment: apiContext.environment),
                                                    supportedCardTypes: supportedCardTypes,
                                                    scope: String(describing: self),
                                                    localizationParameters: localizationParameters)
        formViewController.delegate = self
        formViewController.cardDelegate = self
        formViewController.title = paymentMethod.name
        return formViewController
    }()
}

extension CardComponent: CardViewControllerDelegate {
    
    func didChangeBIN(_ value: String) {
        self.cardComponentDelegate?.didChangeBIN(String(value.prefix(Constant.publicBinLength)), component: self)
        binInfoProvider.provide(for: value, supportedTypes: supportedCardTypes) { [weak self] binInfo in
            guard let self = self else { return }
            // update response with sorted brands
            var binInfo = binInfo
            binInfo.brands = CardBrandSorter.sortBrands(binInfo.brands ?? [])
            self.cardViewController.update(binInfo: binInfo)
            self.cardComponentDelegate?.didChangeCardBrand(binInfo.brands ?? [], component: self)
        }
    }
    
}
