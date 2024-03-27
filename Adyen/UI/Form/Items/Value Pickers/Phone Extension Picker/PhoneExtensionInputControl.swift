//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A control to select a phone extension from a list.
internal final class PhoneExtensionInputControl: BasePickerInputControl {

    /// The country code view.
    internal lazy var countryCodeLabel: UILabel = {
        let label = UILabel()
        label.adyen.apply(style)
        return label
    }()

    override internal func setupView() {
        let stackView = UIStackView(arrangedSubviews: [countryCodeLabel, chevronView, valueLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        stackView.isUserInteractionEnabled = false
        
        addSubview(stackView)
        stackView.adyen.anchor(inside: self, with: .init(top: 0, left: 0, bottom: -1, right: -6))
    }

}
