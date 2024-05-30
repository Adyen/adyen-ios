//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a form for the user to enter details.
internal final class FormView: UIView {

    /// Initializes the form view.
    internal init() {
        super.init(frame: .zero)
        
        preservesSuperviewLayoutMargins = true
        addSubview(stackView)
//        isScrollEnabled = false
        configureConstraints()
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal var intrinsicContentSize: CGSize {
        stackView.adyen.minimalSize
    }
    
    // MARK: - Item Views
    
    /// Appends an item view to the stack of item views.
    ///
    /// - Parameter itemView: The item view to append.
    internal func appendItemView(_ itemView: UIView) {
        stackView.addArrangedSubview(itemView)
    }

    // MARK: - Stack View
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.preservesSuperviewLayoutMargins = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Layout

    private func configureConstraints() {
//        stackView.adyen.anchor(inside: self)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
//        stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
