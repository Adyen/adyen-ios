//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
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
        accessory = .customView(detectedBrandsView)
        textField.textContentType = .creditCardNumber
        textField.returnKeyType = .default
        textField.allowsEditingActions = false
        
        observe(item.$initialBrand) { [weak self] _ in
            guard let self else { return }
            self.updateValidationStatus(forced: true)
            self.notifyDelegateOfMaxLengthIfNeeded()
        }
        
        observe(item.$detectedBrandLogos) { [weak self] newValue in
            self?.detectedBrandsView.updateCurrentLogos(newValue)
        }
    }
    
    override public func handleFormattedValueDidChange(_ newValue: String) {
        updateValidationStatus()
    }
    
    @_spi(AdyenInternal)
    override public func textDidChange(textField: UITextField) {
        // Overriding to not use the default behavior of the super class
        _ = item.textDidChange(value: textField.text ?? "")
        notifyDelegateOfMaxLengthIfNeeded()
    }
    
    @_spi(AdyenInternal)
    override public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        let shouldChange = item.textField(
            textField,
            shouldChangeCharactersIn: range,
            replacementString: string
        )
        
        if !shouldChange {
            // If shouldChange is false, textDidChange(textField:) is not triggered
            // So we need to trigger the logic ourselves
            textDidChange(textField: textField)
        }
        
        return shouldChange
    }
    
    override internal func textFieldDidBeginEditing(_ text: UITextField) {
        super.textFieldDidBeginEditing(text)
        // change accessory back only if brand is supported or empty
        if item.initialBrand?.isSupported ?? true {
            accessory = .customView(detectedBrandsView)
        }
        item.isActive = true
    }
    
    override internal func textFieldDidEndEditing(_ text: UITextField) {
        super.textFieldDidEndEditing(text)
        if accessory == .valid {
            accessory = .customView(detectedBrandsView)
        }
        item.isActive = false
    }
    
    // MARK: - Card Type Logos View
    
    /// Logo view for the brand(s) icons and selection for dual-branded cards.
    internal lazy var detectedBrandsView: DualBrandView = {
        let cardTypeLogosView = DualBrandView(style: item.style.icon, onBrandSelection: { [weak self] index in
            self?.item.selectBrand(at: index)
        })
        cardTypeLogosView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardTypeLogos")
        cardTypeLogosView.backgroundColor = item.style.backgroundColor
        return cardTypeLogosView
    }()
}
