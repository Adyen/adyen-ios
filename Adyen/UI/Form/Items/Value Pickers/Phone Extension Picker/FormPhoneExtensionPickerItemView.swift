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
    
    internal lazy var valueLabel = UILabel(style: item.style.text)
    
    internal var accessoryImage: UIImage? { UIImage(
        named: "chevron_down",
        in: Bundle.coreInternalResources,
        compatibleWith: nil
    ) }
    
    internal lazy var chevronView = UIImageView(image: accessoryImage)
    
    /// The country code view.
    internal lazy var countryCodeLabel: UILabel = {
        let label = UILabel()
        label.adyen.apply(item.style.text)
        return label
    }()
    
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
        
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(handleSelection), for: .touchUpInside)
        
        button.addSubview(stackView)
        addSubview(button)
        
        stackView.adyen.anchor(inside: button)
        button.adyen.anchor(inside: self, with: .init(top: 0, left: 0, bottom: -1, right: -6))
    }
    
    internal func updateSelection() {
        countryCodeLabel.text = item.value?.identifier
        valueLabel.text = item.value?.subtitle
    }
    
    @objc
    private func handleSelection() {
        item.selectionHandler()
    }
}
