//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal typealias InstallmentPickerElement = BasePickerElement<InstallmentElement>

internal final class FormCardInstallmentsItemView: BaseFormPickerItemView<InstallmentElement> {
    override internal func initialize() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, inputControl])
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.adyen.anchor(inside: self)
    }
}
