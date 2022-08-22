//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A `UIViewController` that shows the pix action UI.
internal final class PixViewController: UIViewController {
    
    /// The view model.
    private let viewModel: PixView.Model
    
    internal lazy var pixView = PixView(model: viewModel)
    
    private lazy var containerView = UIView(frame: .zero)
    
    /// Initializes the `PixViewController`.
    ///
    /// - Parameter viewModel: The view model.
    /// - Parameter style: The UI style.
    internal init(viewModel: PixView.Model) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle(for: PixViewController.self))
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(pixView)
        view.addSubview(containerView)
        configureConstraints()
        view.backgroundColor = viewModel.style.backgroundColor
    }
    
    private func configureConstraints() {
        pixView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)
        let constraints = [
            pixView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            pixView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
            pixView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
            
            pixView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pixView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
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
