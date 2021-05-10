//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Delegate for observing user's activity on `BCMCComponent`.
public protocol BCMCComponentDelegate: AnyObject {
    
    /// Called when user enters PAN in `BCMCComponent`.
    /// - Parameter value: Up to 6 first digits in entered PAN.
    /// - Parameter component: The `BCMCComponent` instance.
    func didChangeBIN(_ value: String, component: BCMCComponent)
    
    /// Called when `BCMCComponent` detected card type(s) in entered PAN.
    /// - Parameter value: True or false if entered value matching Bancontact card. Null - if no data entered.
    /// - Parameter component: The `BCMCComponent` instance.
    func didChangeCardType(_ value: Bool?, component: BCMCComponent)
}

/// A component that handles BCMC card payments.
public final class BCMCComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// The card payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// The delegate for user activity on component.
    public weak var bcmcComponentDelegate: BCMCComponentDelegate?
    
    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controllers's title.
    /// Defaults to true.
    @available(*, deprecated, message: """
     The `showsLargeTitle` property is deprecated.
     For Component title, please, introduce your own lable implementation.
     You can access componet's title from `viewController.title`.
    """)
    public var showsLargeTitle: Bool {
        get {
            guard !_isDropIn else { return false }
            return cardComponent._showsLargeTitle
        }
        
        set {
            cardComponent._showsLargeTitle = newValue
        }
    }
    
    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    public var showsHolderNameField: Bool {
        get {
            cardComponent.showsHolderNameField
        }
        
        set {
            cardComponent.showsHolderNameField = newValue
        }
    }
    
    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    public var showsStorePaymentMethodField: Bool {
        get {
            cardComponent.showsStorePaymentMethodField
        }
        
        set {
            cardComponent.showsStorePaymentMethodField = newValue
        }
    }
    
    /// :nodoc:
    public var clientKey: String? {
        get {
            cardComponent.clientKey
        }
        
        set {
            cardComponent.clientKey = newValue
        }
    }
    
    /// :nodoc:
    public var environment: Environment {
        get {
            cardComponent.environment
        }
        
        set {
            cardComponent.environment = newValue
        }
    }

    /// Stored card configuration.
    public var storedCardConfiguration: StoredCardConfiguration {
        get {
            cardComponent.storedCardConfiguration
        }

        set {
            cardComponent.storedCardConfiguration = newValue
        }
    }
    
    /// Initializes the Bancontact component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Bancontact payment method.
    ///   - cardComponent: The card component.
    ///   - style: The Component's UI style.
    internal init(paymentMethod: BCMCPaymentMethod,
                  cardComponent: CardComponent,
                  style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.cardComponent = cardComponent
        self.cardComponent.delegate = self
        self.cardComponent.cardComponentDelegate = self
        self.cardComponent.excludedCardTypes = []
        self.cardComponent.supportedCardTypes = [.bcmc]
        self.cardComponent.showsSecurityCodeField = false
        self.cardComponent.storedCardConfiguration.showsSecurityCodeField = false
    }
    
    /// Initializes the Bancontact component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Bancontact payment method.
    ///   -  clientKey: The client key that corresponds to the webservice user you will use for initiating the payment.
    /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
    ///   - style: The Component's UI style.
    public convenience init(paymentMethod: BCMCPaymentMethod,
                            clientKey: String,
                            style: FormComponentStyle = FormComponentStyle()) {
        let cardComponent = CardComponent(paymentMethod: paymentMethod,
                                          clientKey: clientKey,
                                          style: style)
        self.init(paymentMethod: paymentMethod, cardComponent: cardComponent)
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var requiresModalPresentation: Bool {
        cardComponent.requiresModalPresentation
    }
    
    /// The payment information.
    public var payment: Payment? {
        get {
            cardComponent.payment
        }
        
        set {
            cardComponent.payment = newValue
        }
    }
    
    /// Returns a view controller that presents the payment details for the shopper to fill.
    public var viewController: UIViewController {
        cardComponent.viewController
    }
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters? {
        get {
            cardComponent.localizationParameters
        }
        
        set {
            cardComponent.localizationParameters = newValue
        }
    }
    
    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - success: Boolean indicating the component should go to a success or failure state.
    ///   - completion: Completion block to be called when animations are finished.
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        cardComponent.stopLoading(withSuccess: success, completion: completion)
    }
    
    // MARK: - Protected
    
    /// :nodoc:
    internal var excludedCardTypes: Set<CardType> { cardComponent.excludedCardTypes }
    
    /// :nodoc:
    internal var supportedCardTypes: [CardType] { cardComponent.supportedCardTypes }

    /// :nodoc:
    internal let cardComponent: CardComponent
}

/// :nodoc:
extension BCMCComponent: CardComponentDelegate {
    
    /// :nodoc:
    public func didChangeBIN(_ value: String, component: CardComponent) {
        bcmcComponentDelegate?.didChangeBIN(value, component: self)
    }
    
    /// :nodoc:
    public func didChangeCardType(_ value: [CardType]?, component: CardComponent) {
        let isCardBCMC = value == nil ? nil : value?.first == CardType.bcmc
        bcmcComponentDelegate?.didChangeCardType(isCardBCMC, component: self)
    }
}

/// :nodoc:
extension BCMCComponent: PaymentComponentDelegate {
    public func didFail(with error: Error, from component: PaymentComponent) {
        if cardComponent === component {
            delegate?.didFail(with: error, from: self)
        } else {
            assertionFailure("passed component should be cardComponent, something went wrong")
            delegate?.didFail(with: error, from: component)
        }
    }
    
    public func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        if cardComponent === component {
            submit(data: data)
        } else {
            assertionFailure("passed component should be cardComponent, something went wrong")
            submit(data: data, component: component)
        }
    }
}

/// :nodoc:
/// Deprecated initializers
public extension BCMCComponent {
    
    /// Initializes the Bancontact component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Bancontact payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    @available(*, deprecated, message: "Use init(paymentMethod:clientKey:style:) instead.")
    convenience init(paymentMethod: BCMCPaymentMethod,
                     publicKey: String,
                     style: FormComponentStyle = FormComponentStyle()) {
        let cardComponent = CardComponent(paymentMethod: paymentMethod,
                                          publicKey: publicKey,
                                          style: style)
        self.init(paymentMethod: paymentMethod, cardComponent: cardComponent)
    }
    
    /// :nodoc:
    /// Initializes a Bancontact component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Bancontact payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    static func component(paymentMethod: BCMCPaymentMethod,
                          publicKey: String,
                          style: FormComponentStyle = FormComponentStyle()) -> BCMCComponent {
        let cardComponent = CardComponent.component(paymentMethod: paymentMethod,
                                                    publicKey: publicKey,
                                                    style: style)
        return BCMCComponent(paymentMethod: paymentMethod, cardComponent: cardComponent, style: style)
    }
}
