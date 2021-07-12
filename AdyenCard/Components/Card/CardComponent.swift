//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/**
 /// A component that provides a form for card payments.

 - SeeAlso:
 [Implementation guidelines](https://docs.adyen.com/payment-methods/cards/ios-component)
 */
public class CardComponent: CardPublicKeyConsumer,
    PresentableComponent,
    Localizable,
    Observer,
    LoadingComponent,
    ClearableComponent {
    
    /// :nodoc:
    public let apiContext: APIContext

    private let publicBinLength = 6

    internal let cardPaymentMethod: AnyCardPaymentMethod

    internal var cardPublicKeyProvider: AnyCardPublicKeyProvider

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
    ///   - style: The Component's UI style.
    public convenience init(paymentMethod: AnyCardPaymentMethod,
                            apiContext: APIContext,
                            configuration: Configuration = Configuration(),
                            style: FormComponentStyle = FormComponentStyle()) {
        let cardPublicKeyProvider = CardPublicKeyProvider(apiContext: apiContext)
        let binInfoProvider = BinInfoProvider(apiClient: APIClient(apiContext: apiContext),
                                              cardPublicKeyProvider: cardPublicKeyProvider)
        self.init(paymentMethod: paymentMethod,
                  apiContext: apiContext,
                  configuration: configuration,
                  style: style,
                  cardPublicKeyProvider: cardPublicKeyProvider,
                  binProvider: binInfoProvider)
    }
    
    /// :nodoc:
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - apiContext: The API context.
    ///   - cardPublicKeyProvider: The card public key provider
    ///   - style: The Component's UI style.
    ///   - configuration: The Card component configuration.
    ///   - binProvider:Any object capable to provide a BinInfo.
    internal init(paymentMethod: AnyCardPaymentMethod,
                  apiContext: APIContext,
                  configuration: Configuration,
                  style: FormComponentStyle,
                  cardPublicKeyProvider: AnyCardPublicKeyProvider,
                  binProvider: AnyBinInfoProvider) {
        self.apiContext = apiContext
        self.cardPaymentMethod = paymentMethod
        self.configuration = configuration
        self.cardPublicKeyProvider = cardPublicKeyProvider
        let paymentMethodCardTypes = paymentMethod.brands.compactMap(CardType.init)
        let excludedCardTypes = configuration.excludedCardTypes
        let allowedCardTypes = configuration.allowedCardTypes ?? paymentMethodCardTypes
        self.supportedCardTypes = allowedCardTypes.minus(excludedCardTypes)
        self.style = style
        self.binInfoProvider = binProvider
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
            component = StoredCardComponent(storedCardPaymentMethod: paymentMethod, apiContext: apiContext)
        } else {
            component = StoredPaymentMethodComponent(paymentMethod: paymentMethod, apiContext: apiContext)
        }
        component.payment = payment
        return component
    }()
    
    // MARK: - Form Items
    
    private lazy var securedViewController = SecuredViewController(child: cardViewController, style: style)
    
    internal lazy var cardViewController: CardViewController = {
        let formViewController = CardViewController(
            configuration: configuration,
            formStyle: style,
            payment: payment,
            logoProvider: LogoURLProvider(environment: apiContext.environment),
            supportedCardTypes: supportedCardTypes,
            scope: String(describing: self)
        )
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self
        formViewController.cardDelegate = self
        formViewController.title = paymentMethod.name
        return formViewController
    }()
    
    // MARK: - ClearableComponent
    
    /// :nodoc:
    public func clear() {
        cardViewController.resetItems()
    }
}

extension CardComponent: CardViewControllerDelegate {
    
    func didChangeBIN(_ value: String) {
        self.cardComponentDelegate?.didChangeBIN(String(value.prefix(publicBinLength)), component: self)
        binInfoProvider.provide(for: value, supportedTypes: supportedCardTypes) { [weak self] binInfo in
            guard let self = self else { return }
            self.cardViewController.update(binInfo: binInfo)
            self.cardComponentDelegate?.didChangeCardBrand(binInfo.brands ?? [], component: self)
        }
    }
    
}
