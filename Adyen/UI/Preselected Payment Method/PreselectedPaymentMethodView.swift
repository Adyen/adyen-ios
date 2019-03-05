//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class PreselectedPaymentMethodView: UIView {
    
    internal init() {
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        configureConstraints()
        
        layoutMargins.top = 32.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Views
    
    internal private(set) lazy var paymentMethodView: ListItemView = {
        let paymentMethodView = ListItemView()
        paymentMethodView.titleAttributes = Appearance.shared.textAttributes
        paymentMethodView.isAccessibilityElement = true
        
        return paymentMethodView
    }()
    
    internal private(set) lazy var payButton = Appearance.shared.payButton()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [paymentMethodView, payButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 32.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
