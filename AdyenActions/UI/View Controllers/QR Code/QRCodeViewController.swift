//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A `UIViewController` that shows the QR code action UI.
internal final class QRCodeViewController: UIViewController {
    
    /// The view model.
    private let viewModel: QRCodeView.Model
    
    /// :nodoc:
    internal lazy var qrCodeView = QRCodeView(model: viewModel)
    
    /// :nodoc:
    private lazy var containerView = UIView(frame: .zero)
    
    /// Initializes the `QRCodeViewController`.
    ///
    /// - Parameter viewModel: The view model.
    /// - Parameter style: The UI style.
    internal init(viewModel: QRCodeView.Model) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle(for: QRCodeViewController.self))
    }
    
    /// :nodoc:
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    override internal func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(qrCodeView)
        view.addSubview(containerView)
        configureConstraints()
        view.backgroundColor = viewModel.style.backgroundColor
    }
    
    /// :nodoc:
    private func configureConstraints() {
        qrCodeView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.adyen.anchor(inside: view.safeAreaLayoutGuide)
        let constraints = [
            qrCodeView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            qrCodeView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
            qrCodeView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
            
            qrCodeView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            qrCodeView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
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
