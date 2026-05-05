//
// Copyright (c) 2019 Adyen N.V.
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
        if item.supportsCardScanning {
            textField.inputAccessoryView = makeCardScanAccessoryView(
                title: item.scanYourCardButtonTitle,
                #selector(openCardScanner)
            )
        }
        textField.textContentType = .creditCardNumber
        textField.returnKeyType = .default
        textField.allowsEditingActions = false
        
        observe(item.$selectedBrand) { [weak self] _ in
            guard let self else { return }
            self.notifyDelegateOfMaxLengthIfNeeded()
        }
        
        observe(item.$detectedBrandLogos) { [weak self] newValue in
            guard let self else { return }
            self.detectedBrandsView.updateCurrentLogos(newValue, mode: self.item.brandDisplayMode)
        }
        
        observe(item.$brandSelection) { [weak self] newValue in
            guard let self else { return }
            self.detectedBrandsView.updateSelection(with: newValue)
        }
    }
    
    override public func handleFormattedValueDidChange(_ newValue: String) {
        textField.text = newValue
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
        if item.selectedBrand?.isSupported ?? true {
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
    
    override internal func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // overridden to detect the touches on the clipped part of the dual brand view
        let convertedPoint = convert(point, to: detectedBrandsView)
        if let hitView = detectedBrandsView.overflowHitTest(point: convertedPoint, with: event) {
            return hitView
        }
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Card Type Logos View
    
    /// Logo view for the brand(s) icons and selection for dual-branded cards.
    internal lazy var detectedBrandsView: DualBrandAccessoryView = {
        let cardTypeLogosView = DualBrandAccessoryView(style: item.style.icon)
        cardTypeLogosView.backgroundColor = item.style.backgroundColor
        cardTypeLogosView.onBrandSelection = { [weak self] selection in
            self?.item.selectBrand(from: selection)
        }
        return cardTypeLogosView
    }()
    
    @objc private func openCardScanner() {
        guard let scanCardHandler = item.scanCardHandler else { return }
        scanCardHandler()
    }
}
