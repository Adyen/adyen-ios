//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A view representing a form card number item.
internal final class FormCardNumberItemView: FormTextItemView<FormCardNumberItem> {
    
    private static let cardSpacing: CGFloat = 4.0
    private static let cardSize = CGSize(width: 24.0, height: 16.0)
    
    /// Initializes the form card number item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormCardNumberItem) {
        super.init(item: item)
        accessory = .customView(cardTypeLogosView)
        textField.textContentType = .creditCardNumber
        textField.returnKeyType = .default
        
        observe(item.$currentBrand) { [weak self] _ in
            self?.updateValidationStatus(forced: true)
        }
    }
    
    override internal func textFieldDidBeginEditing(_ text: UITextField) {
        super.textFieldDidBeginEditing(text)
        // change accessory back only if brand is supported or empty
        if item.currentBrand?.isSupported ?? true {
            accessory = .customView(cardTypeLogosView)
        }
        item.isActive = true
    }
    
    override internal func textFieldDidEndEditing(_ text: UITextField) {
        super.textFieldDidEndEditing(text)
        if accessory == .valid {
            accessory = .customView(cardTypeLogosView)
        }
        item.isActive = false
    }
    
    // MARK: - Card Type Logos View
    
    internal lazy var cardTypeLogosView: UIView = {
        let cardTypeLogosView = UIView()
        cardTypeLogosView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardTypeLogos")
        cardTypeLogosView.backgroundColor = item.style.backgroundColor
        
        return cardTypeLogosView
    }()
}
