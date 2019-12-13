//
// Copyright (c) 2019 Adyen N.V.
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
    
    /// :nodoc:
    internal var excludedCardTypes: Set<CardType> { cardComponent.excludedCardTypes }
    
    /// :nodoc:
    internal var supportedCardTypes: [CardType] { cardComponent.supportedCardTypes }
    
    private let cardComponent: CardComponent
    
    /// Initializes the Bancontact component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Bancontact payment method.
    ///   - publicKey: The key used for encrypting card data.
    public init(paymentMethod: BCMCPaymentMethod, publicKey: String) {
        self.paymentMethod = paymentMethod
        self.cardComponent = CardComponent(paymentMethod: paymentMethod, publicKey: publicKey)
        self.cardComponent.excludedCardTypes = []
        self.cardComponent.supportedCardTypes = [.bcmc]
        self.cardComponent.showsSecurityCodeField = false
        self.cardComponent.delegate = self
    }
    
    // MARK: - Presentable Component Protocol
    
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
        get {
            return cardComponent.viewController
        }
        
        set {
            cardComponent.viewController = newValue
        }
    }
    
    /// The preferred way of presenting this component.
    public var preferredPresentationMode: PresentableComponentPresentationMode { cardComponent.preferredPresentationMode }
    
    /// :nodoc:
    public var localizationTable: String? {
        get {
            return cardComponent.localizationTable
        }
        
        set {
            cardComponent.localizationTable = newValue
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
            delegate?.didSubmit(data, from: self)
        } else {
            assertionFailure("passed component should be cardComponent, something went wrong")
            delegate?.didSubmit(data, from: component)
        }
    }
}
