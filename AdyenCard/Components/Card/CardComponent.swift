//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Delegate for observing user's activity on `CardComponent`.
public protocol CardComponentDelegate: AnyObject {
    
    /// Called when user enters PAN in `CardComponent`.
    /// - Parameter value: Up to 6 first digits in entered PAN.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeBIN(_ value: String, component: CardComponent)
    
    /// Called when `CardComponent` detected card type(s) in entered PAN.
    /// - Parameter value: Array of card types matching entered value. Null - if no data entered.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent)
}

/// A component that provides a form for card payments.
public class CardComponent: PaymentComponent, PresentableComponent, Localizable, Observer, LoadingComponent {

    private let publicBinLength = 6
    internal let cardPaymentMethod: AnyCardPaymentMethod
    internal var cardPublicKeyProvider: AnyCardPublicKeyProvider
    internal var cardBrandProvider: AnyCardBrandProvider
    
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
    
    /// :nodoc:
    public var environment: Environment = .live {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.environment = environment
            storedCardComponent?.environment = environment
            cardBrandProvider.environment = environment
        }
    }
    
    /// :nodoc:
    public var clientKey: String? {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.clientKey = clientKey
            storedCardComponent?.clientKey = clientKey
            cardBrandProvider.clientKey = clientKey
        }
    }
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   -  clientKey: The client key that corresponds to the webservice user you will use for initiating the payment.
    /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
    ///   -  style: The Component's UI style.
    public convenience init(paymentMethod: AnyCardPaymentMethod,
                            configuration: Configuration,
                            clientKey: String,
                            style: FormComponentStyle = FormComponentStyle()) {
        self.init(paymentMethod: paymentMethod,
                  configuration: configuration,
                  cardPublicKeyProvider: CardPublicKeyProvider(),
                  clientKey: clientKey,
                  style: style)
    }
    
    /// :nodoc:
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - cardPublicKeyProvider: The card public key provider
    ///   - style: The Component's UI style.
    internal init(paymentMethod: AnyCardPaymentMethod,
                  configuration: Configuration = Configuration(),
                  cardPublicKeyProvider: AnyCardPublicKeyProvider = CardPublicKeyProvider(),
                  clientKey: String,
                  style: FormComponentStyle = FormComponentStyle()) {
        self.clientKey = clientKey
        self.cardPaymentMethod = paymentMethod
        self.configuration = configuration
        self.cardPublicKeyProvider = cardPublicKeyProvider
        let paymentMethodCardTypes = paymentMethod.brands.compactMap(CardType.init)
        let excludedCardTypes = configuration.excludedCardTypes
        let allowedCardTypes = configuration.allowedCardTypes ?? paymentMethodCardTypes
        self.supportedCardTypes = allowedCardTypes.minus(excludedCardTypes)
        self.style = style
        self.cardBrandProvider = CardBrandProvider(cardPublicKeyProvider: cardPublicKeyProvider)
        self.cardPublicKeyProvider.clientKey = clientKey
        self.cardBrandProvider.clientKey = clientKey
        self.environment.clientKey = clientKey
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
            component = StoredCardComponent(storedCardPaymentMethod: paymentMethod)
        } else {
            component = StoredPaymentMethodComponent(paymentMethod: paymentMethod)
        }
        component.clientKey = clientKey
        component.environment = environment
        component.payment = payment
        return component
    }()
    
    // MARK: - Form Items
    
    private lazy var securedViewController = SecuredViewController(child: cardViewController, style: style)
    
    internal lazy var cardViewController: CardViewController = {
        let formViewController = CardViewController(configuration: configuration,
                                                    formStyle: style,
                                                    payment: payment,
                                                    logoProvider: LogoURLProvider(environment: environment),
                                                    supportedCardTypes: supportedCardTypes,
                                                    scope: String(describing: self))
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self
        formViewController.cardDelegate = self
        formViewController.title = paymentMethod.name
        return formViewController
    }()

}

extension CardComponent: CardViewControllerDelegate {
    
    func didChangeBIN(_ value: String) {
        self.cardComponentDelegate?.didChangeBIN(String(value.prefix(publicBinLength)), component: self)
        let parameters = CardBrandProviderParameters(bin: value, supportedTypes: supportedCardTypes)
        cardBrandProvider.provide(for: parameters) { [weak self] binInfo in
            guard let self = self else { return }
            self.cardViewController.update(binInfo: binInfo)
            self.cardComponentDelegate?.didChangeCardBrand(binInfo.brands ?? [], component: self)
        }
    }
    
}
