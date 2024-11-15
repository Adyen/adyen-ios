//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a form for the user to enter details.
internal final class FormView: UIView {

    // MARK: - UI elements

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Properties
    
    /// A Boolean value that determines whether the `FormView` is embedded in a `UIScrollView`
    internal var isEmbeddedInScrollView: Bool = true

    /// Initializes the form view.
    internal init() {
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal var intrinsicContentSize: CGSize {
        isEmbeddedInScrollView ? stackView.adyen.minimalSize : super.intrinsicContentSize
    }
    
    // MARK: - Item Views
    
    /// Appends an item view to the stack of item views.
    ///
    /// - Parameter itemView: The item view to append.
    internal func appendItemView(_ itemView: UIView) {
        stackView.addArrangedSubview(itemView)
    }

    // MARK: - Private

    private func setup() {
        addSubviews()
        setupLayout()
    }

    private func addSubviews() {
        addSubview(stackView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
}
