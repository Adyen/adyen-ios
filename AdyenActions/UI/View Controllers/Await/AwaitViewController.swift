//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A `UIViewController` that shows the await action UI.
internal final class AwaitViewController: UIViewController {
    
    /// The view model.
    private let viewModel: AwaitComponentViewModel
    
    /// The UI style.
    private let style: AwaitComponentStyle
    
    /// :nodoc:
    internal lazy var awaitView = AwaitView(viewModel: viewModel, style: style)
    
    /// :nodoc:
    private lazy var containerView = UIView(frame: .zero)
    
    /// Initializes the `AwaitViewController`.
    ///
    /// - Parameter viewModel: The view model.
    /// - Parameter style: The UI style.
    internal init(viewModel: AwaitComponentViewModel,
                  style: AwaitComponentStyle = AwaitComponentStyle()) {
        self.viewModel = viewModel
        self.style = style
        super.init(nibName: nil, bundle: Bundle(for: AwaitViewController.self))
    }
    
    /// :nodoc:
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    override internal func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(awaitView)
        view.addSubview(containerView)
        configureConstraints()
        view.backgroundColor = style.backgroundColor
    }
    
    /// :nodoc:
    private func configureConstraints() {
        awaitView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)
        let constraints = [
            awaitView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            awaitView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
            awaitView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
            
            awaitView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            awaitView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// :nodoc:
    override internal var preferredContentSize: CGSize {
        get {
            containerView.adyen.minimalSize
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
    
}
