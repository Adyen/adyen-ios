//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A `UIStackView` subclass designed to display form elements. Elements to be displayed in the form should be added via `addArrangedSubview(_:)`.
internal class FormView: UIStackView {
    
    internal init() {
        super.init(frame: .zero)
        
        axis = .vertical
        spacing = 22.0
        layoutMargins = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        isLayoutMarginsRelativeArrangement = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
