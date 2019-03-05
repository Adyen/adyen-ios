//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Defines the methods that should be implemented in order to add card scanning functionality to checkout flow.
public protocol CardScanDelegate: AnyObject {
    /// Invoked when the Card Plugin wants to know whether a card scanning option should be presented to the user.
    ///
    /// - Parameter paymentMethod: The payment method that is currently selected.
    /// - Returns: A boolean value indicating whether a card scanning option should be presented to the user.
    func isCardScanEnabled(for paymentMethod: PaymentMethod) -> Bool
    
    /// Invoked when the user has selected the card scanning option.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method that is currently selected.
    ///   - completion: The closure to invoke when the user has scanned its card.
    func scanCard(for paymentMethod: PaymentMethod, completion: @escaping CardScanCompletion)
}

/// A typealias describing the handler that should be invoked when the user has scanned its card.
public typealias CardScanCompletion = Completion<(holderName: String?, number: String?, expiryDate: String?, securityCode: String?)>

// MARK: - Setting the Card Scan Delegate

public extension CheckoutController {
    /// Entry point to configure card scanning functionality.
    var cardScanDelegate: CardScanDelegate? {
        get {
            return CardPlugin.cardScanDelegate
        }
        set {
            CardPlugin.cardScanDelegate = newValue
        }
    }
}
