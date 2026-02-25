//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

internal protocol StoredPaymentInputViewModelProtocol: AnyObject {
    var cardImageItem: CardImageItem { get }
    var titleText: String { get }
    var subtitleText: String { get }

    var inputFieldTitle: String { get }
    var inputFieldSubTitle: String { get }

    var submitButtonTitle: String { get }
    func submitPayment()

    var showAllPaymentMethodsButtonTitle: String { get }
    func showAllPaymentMethods()

    var theme: AdyenTheme { get }
}

internal final class StoredPaymentInputViewModel: StoredPaymentInputViewModelProtocol {
    var cardImageItem: AdyenUI.CardImageItem {
        CardImageItem(imageURL: nil, sizeMode: .fixed(CGSizeZero))
    }

    internal var titleText: String {
        "Enter security code"
    }

    internal var subtitleText: String {
        "Enter the security code for Visa *** to complete the payment of $140"
    }

    internal var inputFieldTitle: String {
        "Security Code"
    }

    internal var inputFieldSubTitle: String {
        "3 digits, back of card"
    }

    internal var submitButtonTitle: String {
        "Pay 140"
    }

    internal var theme: AdyenTheme = .init()

    internal func submitPayment() {}

    internal var showAllPaymentMethodsButtonTitle: String {
        "Other payment options"
    }

    internal func showAllPaymentMethods() {}
}
