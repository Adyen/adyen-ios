//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A control to select a phone extension from a list.
@_spi(AdyenInternal)
public final class FormPhoneExtensionPickerItemView: FormItemView<FormPhoneExtensionPickerItem> {
    
    private enum Constants {
        static let chevronImageName = "chevron_down"
    }
    
    private lazy var valueLabel = UILabel(style: item.style.text)
    
    private lazy var chevronView: UIImageView = {
        let image = UIImage(
            named: Constants.chevronImageName,
            in: Bundle.coreInternalResources,
            compatibleWith: nil
        )
        
        let chevronView = UIImageView(image: image)
        chevronView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return chevronView
    }()
    
    /// The country code view.
    private lazy var countryCodeLabel: UILabel = {
        let label = UILabel()
        label.adyen.apply(item.style.text)
        return label
    }()
    
    override public var accessibilityIdentifier: String? {
        didSet {
            valueLabel.accessibilityIdentifier = accessibilityIdentifier.map {
                ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "label")
            }
        }
    }
    
    public required init(item: FormPhoneExtensionPickerItem) {
        super.init(item: item)
        setupView()
        updateSelection()
        
        item.selectionHandler = { [weak self] in
            
            let topPresenter = self?.item.presenter
            
            let pickerViewController = FormPickerSearchViewController(
                localizationParameters: item.localizationParameters,
                title: item.title,
                options: item.selectableValues
            ) { [weak topPresenter, weak self] selectedItem in
                self?.item.value = selectedItem
                self?.updateSelection()
                topPresenter?.dismissViewController(animated: true)
            }
            
            item.presenter?.presentViewController(pickerViewController, animated: true)
        }
    }
    
    internal func setupView() {
        let stackView = UIStackView(arrangedSubviews: [countryCodeLabel, chevronView, valueLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        stackView.isUserInteractionEnabled = false
        // Phone numbers in RTL languages are still read left to right
        // so we force it into this mode so the StackView order is consistent
        stackView.semanticContentAttribute = .forceLeftToRight
        
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(handleSelection), for: .touchUpInside)
        
        button.addSubview(stackView)
        addSubview(button)
        
        stackView.adyen.anchor(inside: button)
        button.adyen.anchor(inside: self, with: .init(top: 0, left: 0, bottom: 1, right: 6))
    }
    
    internal func updateSelection() {
        countryCodeLabel.text = item.value?.countryCode
        valueLabel.text = item.value?.value
    }
    
    @objc
    private func handleSelection() {
        item.selectionHandler()
    }
}
