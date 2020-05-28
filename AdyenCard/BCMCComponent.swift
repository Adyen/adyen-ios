//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles BCMC card payments.
public final class BCMCComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// The card payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controllers's title.
    /// Defaults to true.
    public var showsLargeTitle: Bool {
        get {
            return cardComponent.showsLargeTitle
        }
        
        set {
            cardComponent.showsLargeTitle = newValue
        }
    }
    
    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    public var showsHolderNameField: Bool {
        get {
            return cardComponent.showsHolderNameField
        }
        
        set {
            cardComponent.showsHolderNameField = newValue
        }
    }
    
    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    public var showsStorePaymentMethodField: Bool {
        get {
            return cardComponent.showsStorePaymentMethodField
        }
        
        set {
            cardComponent.showsStorePaymentMethodField = newValue
        }
    }
    
    /// Initializes the Bancontact component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Bancontact payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    public init(paymentMethod: BCMCPaymentMethod,
                publicKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.cardComponent = CardComponent(paymentMethod: paymentMethod,
                                           publicKey: publicKey,
                                           style: style)
        self.cardComponent.excludedCardTypes = []
        self.cardComponent.supportedCardTypes = [.bcmc]
        self.cardComponent.showsSecurityCodeField = false
        self.cardComponent.delegate = self
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var requiresModalPresentation: Bool {
        return cardComponent.requiresModalPresentation
    }
    
    /// The payment information.
    public var payment: Payment? {
        get {
            return cardComponent.payment
        }
        
        set {
            cardComponent.payment = newValue
        }
    }
    
    /// Returns a view controller that presents the payment details for the shopper to fill.
    public var viewController: UIViewController {
        return cardComponent.viewController
    }
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters? {
        get {
            return cardComponent.localizationParameters
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
    
    // MARK: - Private
    
    private let cardComponent: CardComponent
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
